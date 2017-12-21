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
  private final static String  SERVER_URL = "http://192.168.1.10"; // 需要修改为report服务器地址
  private final static String  REPORT_URL = "http://192.168.1.10/ReportServer/Pages/ReportViewer.aspx"; // 需要修改为report服务器对应地址
  // 该文件主要处理SSRS的动态请求等
%>
<%
  // 请在这里添加你网站自己的认证信息 Start
  // TO-DO:
  // End
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

      Enumeration paramEnum = request.getParameterNames();
      String currentParam;
      while(paramEnum.hasMoreElements()) {
        currentParam = (String) paramEnum.nextElement();
        if (!"reportName".equals(currentParam)) {
          if (request.getParameter(currentParam) == null || "".equals(request.getParameter(currentParam))) {
            if (parameterString != "") {
              parameterString += "&";
            }
            parameterString += URLEncoder.encode(currentParam, "UTF-8");
          } else {
            if (parameterString != "") {
              parameterString += "&";
            }
            parameterString += URLEncoder.encode(currentParam, "UTF-8") + "=" + URLEncoder.encode(request.getParameter(currentParam), "UTF-8");
          }
        }
      }
      String urlString = null;

      // Establish HTTP GET connection to report server
      if(requestMethod.equals("GET")) {
        urlString = REPORT_URL + "?" + parameterString;
      }else if(requestMethod.equals("POST")) {
        urlString = REPORT_URL + "?";
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

      serverConnection.setRequestMethod("POST");
      serverConnection.setDoOutput(true);
      serverConnection.setUseCaches(false);
      serverConnection.setFollowRedirects(false);
      serverConnection.setRequestProperty("User-Agent", "Mozilla/5.0");
      serverConnection.setRequestProperty("Content-type", "application/x-www-form-urlencoded");
      serverConnection.setRequestProperty("Content-length", Integer.toString(parameterString.length()));

      // Send parameter string to report server
      PrintWriter repOutStream = new PrintWriter(serverConnection.getOutputStream());
      repOutStream.println(parameterString);
      repOutStream.close();

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

    // Use a buffered stream to send all binary formats.
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
    private String username = "TRIZ-HAOJIN\\report"; // 需要修改为report服务器的认证
    private String password = "111111Rp";// 需要修改为report服务器的认证

    public ReportAuthenticator() {}

    protected PasswordAuthentication getPasswordAuthentication()
    {
      return new PasswordAuthentication(username,(password.toCharArray()));
    }
  }

%>



