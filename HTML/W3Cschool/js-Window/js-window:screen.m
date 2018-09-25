/*
 Window 浏览器对象
*/
 浏览器对象模型(Browser Object Model) 尚无正式标准
 由于现代浏览器已经(几乎)实现了JavaScript交互性方面的相同方法和属性，因此常被认为是BOM的方法和属性
 所有浏览器都支持Window 对象。它表示浏览器窗口。

 所有JavaScript全局对象、函数以及变量均自动成为Window对象的成员。
 全局变量是Window对象的属性
 全部函数是Window对象的方法
 甚至HTML DOM的document 也是 window 对象的属性之一

 window.document.getElementById("header")
 == (等价)
 document.getElementById("header")



/*
 Window 尺寸
*/
 有三种方法能够确定浏览器窗口的尺寸(浏览器的视口，不包括工具栏和滚动条)

 对于Internet Explorer, Chrome, FireFox, Opera, Safari:
   .window.innerHeight  -- 浏览器窗口的内部高度
   .window.innerWidth   -- 浏览器窗口的内部宽度

 对于Internet Explorer 8 7 6 5:
   .document.documentElement.clientHeight
   .document.documentElement.clientWidth
 或者
   .document.body.clientHeight
   .document.body.clientWidth

 兼容方案
 eg:
  var w = window.innerWidth
  || document.documentElement.clientWidth
  || document.body.clientWidth

  var h = window.innerHeight
  || document.documentElement.clientHeight
  || document.body.clientHeight


/*
 其他Window 方法
*/
 .window.open()     -打开新窗口
 .window.close()    -关闭当前窗口
 .window.moveTo()   -移动当前窗口
 .window.resizeTo() -调整当前窗口的尺寸



/*
 window.screen 对象包含有关用户屏幕的信息
*/
window.screen 对象在编写时可以不使用window这个前缀
一些属性:
 .screen.availWidth   -可用的屏幕宽度
 .screen.availHeight  -可用的屏幕高度
 //以像素计 减去界面特性 比如窗口任务栏












