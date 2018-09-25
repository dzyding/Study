1. 用于字符串的 + 运算符
 /*
 + 运算符用于把文本值或字符串变量加起来 （链接起来）
 如果把两个或多个字符串变量链接起来， 请使用 + 运算符
 */
 eg:
  txt1 = "What a very";
  txt2 = "nice day";
  txt3 = txt1 + txt2;
  txt4 = txt1 + " " + txt2;  // 添加一个空格

 eg:
  x = 5 + 5
  document.write(x);
  // 10

  x = "5" + "5"
  document.write(x);
  // 55

  x = 5 + "5";
  document.write(x);
  // 55

  x = "5" + 5;
  document.write(x);
  // 55

 //总结: 如果把数字与字符串相加，结果将成为字符串。


2.比较和逻辑运算符

 // 全等（值和类型）
 ===

 x = 5;
 x === 5  为true 
 x ==="5" 为false


 //比较运算符使用方式
 if (age < 18) document.write("Too young");

 //逻辑运算符
 && -- and
 || -- or
 !  -- not


3.条件运算符 （不就是尼玛三目运算符么）
 
 //JavaScript 还包含了基于某些条件对变量进行赋值的条件运算符.
 语法:
  variablename = (condition) ? value1 : value2 
 eg:
  greeting = (visitor == "PRES") ? "Dear Persident" : "Dear" ;


4.for/in
 // JavaScript 的for/in 循环好像是用来遍历对象属性的.? 
 eg:
  var person = {fname:"John", lname:"Doe", age:25};
  for (x in person) {
  	txt = txt + person[x];
  }

5.Javascript 标签  配合break使用 跳出代码块
 eg:
  cars = ["BWM", "Volvo", "Saab", "Ford"];
  list:
  {
  	document.write(cars[0] + "<br>");
  	document.write(cars[1] + "<br>");
  	document.write(cars[2] + "<br>");
  	break list;
  	document.write(cars[3] + "<br>");
  	document.write(cars[4] + "<br>");
  }







