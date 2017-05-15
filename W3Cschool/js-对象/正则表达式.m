/*
 JavaScript RegExp 对象
*/
 RegExp 对象用于规定在文本中检索的内容



/*
 定义RegExp
*/
 eg: 
  var patt1 = new RegExp("e") 
  //定义了名为patt1 的 RegExp 对象，其模式是"e"
  //当你使用该RexExp对象在一个字符串中检索时，将寻找的是字符"e"


/*
 RegExp 对象的方法
*/
 .test()  //检索字符串中的指定值。返回值是true 或 false
  eg:
   var patt1 = new RegExp("e")
   document.write(patt1.test("The best things in life are free"))     //true

 .exec()  //检索字符串中的指定值。返回值是被找到的值。如果没有发现匹配，则返回null
  eg1:
   var patt1 = new RegExp("e")
   document.write(patt1.exec("The best things in life are free"))     //e
 
  /*
    可以向RegExp 对象添加第二个参数，以设定检索。
    例如如果需要找到某个字符的所有存在，则可以使用"g"参数  表示"global"
    原理如下:
      .找到第一个"e"，并存储其位置
      .如果再次运行exec()，则从存储的位置开始检索，并找到下一个"e"，并存储其位置
  */
  eg2:
   var patt1 = new RegExp("e","g")
   do {
   	result = patt1.exec("The best things in life are free")
   	document.write(result)
   }
   while(result != null)
   //结果:  eeeeeenull


 .compile()  //用于改变RegExp 既可以改变检索模式，也可以添加或删除第二个参数
 eg:
  var patt1 = new RegExp("e")
  document.write(patt1.test("The best things in life are free"))
  patt1.compile("d")
  document.write(patt1.test("The best things in life are free"))
  //结果:   true false
























