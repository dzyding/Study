/*
 window.navigator 
*/
 该对象包含有关访问者浏览器的信息
 window.navigator 对象在编写时可不使用window这个前缀
 eg: 
  <div id = "example"></div>
  <script>
   txt  = "<p>Browser CodeName: " + navigator.appCodeName + "</p>"
   txt += "<p>Browser Name: " + navigator.appName + "</p>"
   txt += "<p>Browser Version " + navigator.appVersion + "</p>"
   txt += "<p>Cookies Enabled " + navigator.cookieEnabled + "</p>"
   txt += "<p>Platform: " + navigator.platform + "</p>"
   txt += "<p>User-agent header: " + navigator.userAgent + "</p>"
   txt += "<p>User-agent language: " + navigator.systemLanguage + "</p>"

   document.getElementById("example").innerHTML = txt
  </script>

  /*
     !! 来自 navigator 对象的信息具有误导性，不应该被用于检测浏览器版本
        1.navigator 数据可被浏览器使用者更改
        2.浏览器无法报告晚于浏览器发布的新操作系统
  */


/*
 浏览器检测
*/
  由于 navigator 可误导浏览器检测，使用对象检测可用来嗅探不同的浏览器 (其实也就是用每个浏览器的独有关键字来辨别浏览器)
  由于不同的浏览器支持不同的对象，可以使用对象来检测浏览器。
  eg:
   由于只有Opera 支持属性 "window.opera" ，可以据此识别出 Opera
   if (window.opera) {
   	...some action...
   }