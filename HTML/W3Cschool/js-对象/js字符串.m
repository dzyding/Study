String

/*
String 对象用于处理已有的字符块
*/

 1.使用长度属性来计算字符串的长度
  eg:
   var txt = "Hello World!"
   document.write(txt.length) 

 2.为字符串添加样式
  eg:
   var txt = "Hello World!"
   document.write("<p>Big:" + txt.big() "</p>")

  其余的:
   txt.big()
   txt.small()
   txt.blod()
   txt.italics()  //倾斜
   txt.blink()    //这个方式不能在IE中工作
   txt.fixed()
   txt.strike()   //横线
   txt.fontcolor("Red")
   txt.fontsize(16)
   txt.toLowerCase()
   txt.toUpperCase()
   txt.sub()      //上标 (右上角)
   txt.sup()      //下标 (右下角)
   txt.link("http://www.w3school.com.cn")  //超链接


 3.indexOf()
   定位字符串中某一个指定的字符首次出现的位置
  eg:
   var str = "Hello world!"
   document.write(str.indexOf("Hello") + "<br/>")   //0
   document.write(str.indexOf("World") + "<br/>")   //-1   不存在
   document.write(str.indexOf("world"))             //6


 4.match()
   查找字符串中特定的字符，并且如果找到的话，则返回这个字符
  eg:
   var str = "Hello world!"
   document.write(str.match("world") + "<br/>")    //world
   document.write(str.match("World!") + "<br/>")   //null
   document.write(str.match("worlld") + "<br/>")   //null
   document.write(str.match("world!"))             //world!

 5.replace()
   在字符串中用某些字符替换另一些字符.
  eg:
   var str = "Visit Microsoft!"
   document.write(str.replace(/Microsoft/,"W3School"))  //Visit W3School























