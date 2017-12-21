<%@ page import = "java.util.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "java.io.*"%>
<%@ page import = "javax.servlet.*"%>
<%@ page import = "javax.servlet.http.*"%>
<%@ page import = "javax.servlet.http.*"%>



<%
    request.getRequestDispatcher("/resource.jsp?go=" + URLEncoder.encode("/ReportServer/Pages/ReportViewer.aspx?"+request.getQueryString(), "UTF-8")).forward(request,response);
%>
