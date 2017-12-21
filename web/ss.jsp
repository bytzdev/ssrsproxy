<%@ page pageEncoding="UTF-8" %>
<%@ page contentType="application/Json;charset=UTF-8"%>
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
    private final static String  SERVER_URL = "http://192.168.1.10";
%>

<%
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
                parameterString += "&" + currentParam + "=" + request.getParameter(currentParam);
            }

            // Establish HTTP GET connection to report server
            String urlString = null;
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

            //Proxy proxy = new Proxy(java.net.Proxy.Type.HTTP,new InetSocketAddress("127.0.0.1", 8888));

            HttpURLConnection serverConnection = (HttpURLConnection) url.openConnection();


            serverConnection.setRequestMethod(requestMethod);
            // serverConnection.setDoOutput(true);
            serverConnection.setUseCaches(false);
            serverConnection.setFollowRedirects(false);
            serverConnection.setRequestProperty("User-Agent", "Mozilla/5.0");
//      serverConnection.setRequestProperty("Content-type", "application/x-www-form-urlencoded");
//      serverConnection.setRequestProperty("Content-length", Integer.toString(parameterString.length()));


            // Send parameter string to report server
            // PrintWriter repOutStream = new PrintWriter(serverConnection.getOutputStream());

            // repOutStream.close();

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

        // Take the server's response and forward it to the client.

//    String cookie = serverConnection.getHeaderField("Set-Cookie");
//    if(cookie == null) {
//      System.out.println("ReportRequest - ERROR: No cookie provided by report server.  Aborting.");
//      return;
//    }
//
//    if(cookie.indexOf(";") != -1) {
//      cookie = cookie.substring(0, cookie.indexOf(";"));
//    }

        String contentType = serverConnection.getContentType();

        clientResponse.setContentType(contentType);
        clientResponse.setHeader("Content-disposition", serverConnection.getHeaderField("Content-disposition"));

        InputStream serverInStream = serverConnection.getInputStream();
        ServletOutputStream clientOutStream = clientResponse.getOutputStream();

        if (!contentType.contains("text/html")) {
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
        } else {
            /*
             * Use a character stream to send HTML to the client, replacing
             */
            String currentWindow = "";
            String url = "";
            int itemsFound = 0;

            for (int ch; (ch = serverInStream.read()) != -1; ) {
                if (currentWindow.length() < REPORT_SERVER.length()) {
                    currentWindow += (char) ch;
                } else if (currentWindow.equalsIgnoreCase(REPORT_SERVER)) {
                    if (ch != '"') {
                        url += (char) ch;
                    } else {
                        itemsFound++;
                        String urlEncode = URLEncoder.encode(url, "UTF-8");
                        if (urlEncode.substring(urlEncode.length() - 3, urlEncode.length()).toUpperCase().equals("%5C")) {
                            urlEncode = urlEncode.substring(urlEncode.length() - 2, urlEncode.length() + 1) + "\\";
                        }
                        clientOutStream.print(RESOURCE_URL + REPORT_SERVER + urlEncode +(char) ch);
                        currentWindow = "";
                        url = "";
                    }
                } else {
                    clientOutStream.print(currentWindow.charAt(0));
                    currentWindow = currentWindow.substring(1) + (char) ch;
                }

                //if(currentWindow.length() < REQUEST_SERVER_URL.length()) {
                //  currentWindow += (char)ch;
                //} else if(currentWindow.equalsIgnoreCase(REQUEST_SERVER_URL) && (char)ch == '?') {
                //  itemsFound++;
//
                //  //clientOutStream.print(REPORT_ITEM_SERVLET_URL + "?cookie=" + cookie + "&");
                //  currentWindow = "";
                //} else {
                //  clientOutStream.print(currentWindow.charAt(0));
                //  currentWindow = currentWindow.substring(1) + (char)ch;
                //}
            }

            clientOutStream.print(currentWindow);

            if (DEBUG) {
                System.out.println("ReportRequest - " + itemsFound + " references to the report server found.");
            }
        }

        serverInStream.close();
        clientOutStream.close();

    }

    public final class ReportAuthenticator extends java.net.Authenticator
    {
        private String username = "TRIZ-HAOJIN\\report";
        private String password = "111111Rp";

        public ReportAuthenticator() {}

        protected PasswordAuthentication getPasswordAuthentication()
        {
            return new PasswordAuthentication(username,(password.toCharArray()));
        }
    }

%>



