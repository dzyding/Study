/*
 window.location 
*/
 该对象用于获得当前界面的地址(URL) 并把浏览器重定向到新的界面
 window.location 对象在编写时可不使用 window 这个前缀

 eg:
  location.hostname      //返回web主机的域名
  location.pathname      //返回当前界面的路径和文件名
  location.port          //返回web主机的端口 80 或 443
  location.protocol      //返回所使用的 web 协议 (http:// 或 https://)
  location.href          //返回当前界面的url
  location.assign()      //该方法用来加载新的文档
  //location.assign("http://www.baidu.com")







/*
 window.history
*/
 该对象包含浏览器的历史
 window.history 对象在编写时可不使用 window 这个前缀
 为了保护用户隐私 对JavaScript访问该对象的方法做出了限制

 history.back()      //与在浏览器点击后退按钮相同
  eg:
  function goback() {
  	window.history.back()
  }

  <input type = "button" value = "Back" onclick = "goBack()">


 history.forward()   //与在浏览器中点击按钮向前相同
  eg:
  function goForward(){
  	window.history.forward()
  }

  <input type = "button" value = "Forward" onclick = "goForward()">