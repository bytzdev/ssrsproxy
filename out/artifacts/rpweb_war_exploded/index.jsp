<html>
<head>
  <title>SSRS PROXY</title>
  <meta http-equiv=Content-Type content="text/html;charset=utf-8">
  <style>
    li{
      padding:2px;
      font-size:13px;
    }
    foot, a{
      font-size:12px;
      color:#333333;
      text-decoration-line: none;
    }
    a:hover{
      font-size:12px;
    }
  </style>
</head>
<body>
  <h3>This is a java server page (jsp) proxy for SSRS 2008. Follow the below contain to config your java server.<br>
      这是SSRS2008的jsp代理服务，请根据如下步骤进行配置。
  </h3>
  <ul>
    <li>If you run in tomcat please add the follow red content to the web.xml.<br/>
      请在你的tomcat的web.xml文件里面添加如下红色内容。<br/>
      <code>
        &lt;servlet-mapping&gt;<br/>
        &lt;servlet-name&gt;jsp&lt;/servlet-name&gt;<br/>
        &lt;url-pattern&gt;*.jsp&lt;/url-pattern&gt;<br/>
        &lt;url-pattern&gt;*.jspx&lt;/url-pattern&gt;<br/>
        <font color="red">&lt;url-pattern&gt;*.axd&lt;/url-pattern&gt;<br/>
        &lt;url-pattern&gt;*.aspx&lt;/url-pattern&gt;<br/>
          &lt;url-pattern&gt;*.ReportServer&lt;/url-pattern&gt;</font><br/>
        &lt;/servlet-mapping&gt;<br/>
      </code>
    </li>
    <li>
      Copy the files to the root of your website(or proxy server), and copy the "lib/commons-lang3-3.3.2.jar" to your library.<br/>
      复制所有文件到你的网站中（或你代理网站中）, 复制"lib/commons-lang3-3.3.2.jar"到你网站的library目录。
    </li>
    <li>
      Change the SSRS authenticator account and password in file  "resource.jsp" and "ReportViewer.aspx".<br/>
      在文件"resource.jsp" and "ReportViewer.aspx"中，更改相关的SSRS认证信息，用户名与密码。
    <li>
      Open your report"http://reportServer/ReportServer/Pages/ReportViewer.aspx?%2ftestReport&rs:Command=Render" in browser.<br/>
      在浏览器中打开你的原始report地址 例如 "http://reportServer/ReportServer/Pages/ReportViewer.aspx?%2ftestReport&rs:Command=Render"。
    </li>
    <li>
      Replace the domain to the proxy server "http://ssrsProxyServer/ReportServer/Pages/ReportViewer.aspx?%2ftestReport&rs:Command=Render".<br/>
      替换里面域名部分为你的代理网站地址 例如"http://ssrsProxyServer/ReportServer/Pages/ReportViewer.aspx?%2ftestReport&rs:Command=Render"。
    </li>
    <li>
      Done and test please.<br/>
      完成并请测试。
    </li>
  </ul>
<foot style="position:absolute;bottom:0px;width: 98%;">
  <center>All rights reversed by <a href="http://www.boya-triz.com">博雅创智</a> Author <a href="mail:haojin@boya-triz.com">郝缙</a>, <a href="mail:xhguo@boya-triz.com">郭兴华</a>, <a href="mail:shanxuezhong@boya-triz.com">单学钟</a>, <a href="mail:zhangpenghui@boya-triz.com">张鹏辉</a></center>
</foot>
</body>
</html>