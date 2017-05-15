
/*
 1.js对象  
*/
  JavaScript 提供多个内建对象，比如String、Date、Array等
  对象只是带有属性和方法的特殊类型


/*
 2.访问对象的属性
*/
  语法:
   objectName.propertyName
  eg:
   var message = "Hello World!";
   var x = message.length;

/*
 3.访问对象的方法
*/
  语法:
   objectName.methodName()
  eg:
   var message = "Hello world!"
   var x = message.toUpperCase()

/*
 4.创建js对象
*/
  js创建对象有两种不同的方法
  1.定义并创建对象的实例
  2.使用函数来定义对象，然后创建新的对象实例
  //  js 是面向对象的语言 但JavaScript不适用类
  //  js 中不会创建类，也不会通过类来创建对象。 JavaScript 基于prototype 而不是基于类的

  eg:
   person = new Object();
   person.firstname = "Bill"
   person.lastname  = "Gates"
   person.age       = 56
   person.eyecolor  = "blue"

   person = {firstname:"Jhon", lastname:"Doe", age:50, eyecolor:"blue"};

/*
 5.对象构造器
*/
  function person(firstname, lastname, age, eyecolor) {
  	this.firstname = firstname
  	this.lastname  = lastname
  	this.age       = age
  	this.eyecolor  = eyecolor
  }

  myFather = new person("Bill", "Gates", 56, "blue")

/*
 6.把属性添加到JavaScript 对象
*/
  eg:  //假设personObj 已存在 您可以为其添加这些新属性 firstname lastname age eyecolor
   person.firstname = "Bill"
   person.lastname  = "Gates"
   person.age       = 56
   person.eyecolor  = "blue"

   x = person.firstname


/*
 7.把方法添加到JavaScript对象
*/
  eg:
   function person(firstname, lastname, age, eyecolor) {
   	this.firstname = firstname
   	this.lastname  = lastname
   	this.age       = age
   	this.eyecolor  = eyecolor

    //这个地方是把changeName 这个方法 赋值给 changeName 属性
   	this.changeName = changeName
   	function changeName(name) {
   		this.changeName = name
   	}
   }

/*
 8.JavaScript  for...in 循环
*/
  语法:
   for (对象中的变量) {
   	要执行的代码
   }
   // for...in 循环中的代码块将针对每个属性执行一次
  
  eg:
   var person = {fname:"Bill", lname:"Gates", age:56}

  for (x in person){
  	txt = txt + person[x];
  }











