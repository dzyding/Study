JavaScript特点.
1.大小写敏感
  // JavaScript 语句 和JavaScript 变量都对大小写敏感
  eg:  getElementById  ! =   getEelementByID
2.忽略空格
  a=b  ==  a = b
3.换行
  eg:
  document.write("Hello \
  World!");

  错误的使用
  document.write \
  ("Hello World!");
4.注释
  单行注释 //
  多行注释 /* */    这个值能在<script></script>  标签里面使用

5.声明个变量
  
  1:)  一次声明多个变量
  var name = "Gates", age = 56, job = "CEO";
  或者
  var name = "Gates",
  age = 56,
  jov = "CEO";

  2:)  声明无值的变量  
  var carname;  //无值变量的值实际上是 undefined

  3:)  重新声明变量
  // 这里carname的值依然是 "Volvo"
  var carname = "Volvo";
  var carname ;

6.变量类型  (基础)
  var x;           // x 为undefined
  var x = 6;       // x 为数字
  var x = "Bill";  // x 为字符串

  1:) 字符串  
  // 字符串可以是 引号中的任意文本。可以使用单引号或者双引号
  eg:
    var carname = "Bill Gates"
    var carname = 'Bill Gates'
  // 可以在字符串中使用引号 只要不匹配包围字符串的引号即可
  eg:
    var answer = "Nice to meet you!";
    var answer = "He is called 'Bill'";
    var answer = 'He is called "Bill"';

  2:) 数字
  // JavaScript 只有一种数字类型 可以带小数点 也可以不带小数点
  eg:
   var x1 = 34.00;
   var x2 = 34;
  // 极大或极小的数字可以通过科学（指数）计数法来书写:
  eg:
   var y = 123e5;  //12300000
   var z = 123e-5; //0.00123

  3:) 布尔
  // 只有两个值 true false
  eg:
   var x = true;
   var y = false;
  
  4:) 数组
  // 基础版本
  eg:
   var cars = new Array();
   cars[0] = "Audi";
   cars[1] = "BMW";
   cars[2] = "Volvo";
  // condensed array
  eg:
   var cars = new Array("Audi", "BMW", "Volvo");
  // literal array
  eg:
   var cars = ["Audi", "BMW", "Volvo"];

7.对象
  // 对象由花括号分隔 在括号内部 对象的属性以名称和值对的形式(name: value)来定义。属性由都好分隔
  eg:
   var person = {firstname : "Bill", lastname : "Gates", id : 5566};
  // 空格和折行无关紧要 声明可横跨多行
  eg:
   var person = {
    firstname : "Bill",
    lastname  : "Gates",
    id        : 5566
   };
  //  对象有两种寻址方式
  eg:
   name = person.lastname;
   name = person["lastname"];

8.Undefined 和 Null
 Undefined 这个值表示变量不含有值
 可以通过将变量设置为 null 来清空变量
 
 eg:
  cars = null;
  person = null;

9.声明变量类型
  // 当您声明新变量时 可以使用关键字 "new" 来声明其类型
  eg:
   var carname = new String;
   var x       = new Number;
   var y       = new Boolean;
   var cars    = new Array;
   var person  = new Object;  
  //  !!!  JavaScript 变量均为对象。 当您声明一个变量时， 就创建了一个新的对象





