<%@ page import = "java.util.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "java.io.*"%>
<%@ page import = "javax.servlet.*"%>
<%@ page import = "javax.servlet.http.*"%>
<%@ page import = "javax.servlet.http.*"%>
<%@ page import="org.apache.commons.lang3.StringEscapeUtils" %>

<%!
  private final static boolean DEBUG = true;
  private final static int BUFFER_SIZE = 2048;
  private final static String  SRC_S = "src=\"";
  private final static String  REPORT_SERVER = "/ReportServer/";
  private final static String  HREF_H = "href=\"";
  private final static String  RESOURCE_URL = "resource.jsp?go=";
  private final static String  SERVER_URL = "http://192.168.1.10"; // 需要修改为report服务器的地址 TO-DO
  // 该文件主要处理SSRS的静态资源
%>

<%
  // 这里可以加验证，也可以不用加 start
  // end
  requestServer(request, response);
%>

<%!
  public void requestServer(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    try {
      if (DEBUG) {
        System.out.println("\nInitializing Request");
        System.out.println("---------------------------");
      }

      Authenticator.setDefault(new ReportAuthenticator());

      // Generate parameter string from request
      String parameterString = "";//"rs:Command=Render&rc:Toolbar=false";
      String requestMethod =  request.getMethod();
      String keepAliveBody="";
      Boolean isKeepAlive = false;
      if (requestMethod.equals("POST")) {
        Enumeration paramEnum = request.getParameterNames();

        String currentParam;

        if("SessionKeepAlive".equals(request.getParameter("OpType"))){
          isKeepAlive=true;
        }

        while(paramEnum.hasMoreElements()) {
          currentParam = (String) paramEnum.nextElement();
          if (!"go".equals(currentParam)) {
            if (request.getParameter(currentParam) == null || "".equals(request.getParameter(currentParam))) {
              if (parameterString != "") {
                parameterString += "&";
              }
              keepAliveBody = currentParam;
              parameterString += currentParam;
            } else {
              if (parameterString != "") {
                parameterString += "&";
              }
              parameterString += currentParam + "=" + request.getParameter(currentParam);
            }
          }
        }
      }
      String urlString = null;

      // Establish HTTP GET connection to report server
      if (request.getParameter("go").contains("http")) {
        urlString = StringEscapeUtils.unescapeHtml4(request.getParameter("go"));
      } else {
        urlString = SERVER_URL + StringEscapeUtils.unescapeHtml4(request.getParameter("go"));
      }

      if(DEBUG)
      {
        System.out.println("ReportRequest - Parameter String: " + parameterString);
        System.out.println("ReportRequest - Report retrieved: " + urlString);
        System.out.println("ReportRequest - Method:" + requestMethod);
      }


      if (urlString == null)
      {
        // Bail out if no report name is found.
        ServletOutputStream responseErrorStream = response.getOutputStream();
        responseErrorStream.println("ERROR: No report name specified");
        responseErrorStream.close();
        return;
      }

      URL url = new URL(urlString);
      // Proxy proxy = new Proxy(java.net.Proxy.Type.HTTP,new InetSocketAddress("127.0.0.1", 8888));
      HttpURLConnection serverConnection = (HttpURLConnection) url.openConnection();

      serverConnection.setRequestMethod(requestMethod);
      if (requestMethod.equals("POST")) {
          serverConnection.setDoOutput(true);
      } else {
        serverConnection.setDoOutput(false);
        // serverConnection.setRequestProperty("Content-type", "application/x-www-form-urlencoded");
      }
      serverConnection.setUseCaches(false);
      serverConnection.setFollowRedirects(false);

      Enumeration headEnum = request.getHeaderNames();
      while(headEnum.hasMoreElements()) {
        String headerName = (String)headEnum.nextElement();
        Set<String> excludeHeaderNames = new HashSet<String>();
        excludeHeaderNames.add("cookie");
        excludeHeaderNames.add("host");
        excludeHeaderNames.add("referer");
        if (!excludeHeaderNames.contains(headerName)) {
          serverConnection.setRequestProperty(headerName, request.getHeader(headerName));
        }
      }

      // Send parameter string to report server
      if (requestMethod.equals("POST")) {
        PrintWriter repOutStream = new PrintWriter(serverConnection.getOutputStream());
        if(isKeepAlive){
          repOutStream.println(keepAliveBody);
        }else {
          repOutStream.println(parameterString);
        }
        repOutStream.close();
      }

      forwardResponse(serverConnection, response);

    } catch (Exception e) {
      e.printStackTrace();

      // Alert the client there has been an error.
      ServletOutputStream responseErrorStream = response.getOutputStream();
      responseErrorStream.println("There has been an error.  Please check the system log for details.");
      responseErrorStream.close();

    }

  }

  private void forwardResponse(HttpURLConnection serverConnection, HttpServletResponse clientResponse) throws ServletException, IOException {
    String contentType = serverConnection.getContentType();

    clientResponse.setContentType(contentType);
    clientResponse.setHeader("Content-disposition", serverConnection.getHeaderField("Content-disposition"));

    InputStream serverInStream = serverConnection.getInputStream();
    ServletOutputStream clientOutStream = clientResponse.getOutputStream();

    BufferedInputStream bis = new BufferedInputStream(serverInStream);
    BufferedOutputStream bos = new BufferedOutputStream(clientOutStream);

    byte[] buff = new byte[BUFFER_SIZE];
    int bytesRead;

    while (-1 != (bytesRead = bis.read(buff, 0, BUFFER_SIZE))) {
      bos.write(buff, 0, bytesRead);
    }
    bis.close();
    bos.close();
    serverInStream.close();
    clientOutStream.close();
  }

  public final class ReportAuthenticator extends java.net.Authenticator
  {
    private String username = "TRIZ-HAOJIN\\report"; // 需要修改为report服务器的认证 TO-DO
    private String password = "111111Rp"; // 需要修改为report服务器的认证 TO-DO

    public ReportAuthenticator() {}

    protected PasswordAuthentication getPasswordAuthentication()
    {
      return new PasswordAuthentication(username,(password.toCharArray()));
    }
  }
%>



