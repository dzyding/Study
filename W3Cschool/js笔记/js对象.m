/*
  JavaScrpt 中所有的事物都是对象： 字符串，数字，数组，日期，等等
  在 JavaScrpt中 对象是拥有属性和方法的数据。
*/

1.属性和方法
 //汽车的属性 
 eg: 
  car.name = Fiat
  car.model = 50
  car.weight = 850kg
  car.color = white 
 //汽车的方法
 eg:
  car.start()
  car.drive()
  car.brake()

2.JavaScript 的对象
 //在JavaScript中，对象是数据（变量），拥有属性和方法
 eg:
  var txt = "Hello";
  //这里实际上已经创建了一个JavaScript字符串对象。字符串对象拥有内建的属性length。这里length = 5
 
 方法
  txt.indexOf()
  txt.replace()
  txt.search()

3.创建JavaScript对象
 //JavaScript中的几乎所有事物都是对象：字符串，数字，数组，日期，函数等等
 //你也可以创建自己的对象，本例创建名为"person"的对象，并为其添加了四个属性
 eg:
  person = new Object();
  person.firstname = "Bill";
  person.lastname = "Gates";
  person.age = 56;
  person.eyecolor = "blue";


 4.简单例子
 
<script>
    /*
      向未声明的JavaScript变量来分配值
      !!!!该变量将会自动作为全局变量声明
    */
    carname = "Benz";

	person = new Object();
	person.firstname = "Bill";
	person.lastname = "Gates";
	person.age = 56;
	person.eyecolor = "blue";
	document.write(person.firstname + " is " + person.age + " years old.");
	var x = person.firstname.length;
	document.write("<br><br>");
	document.write(x);
	var y = person.firstname + person.lastname;
	y = y.toUpperCase();
	document.write("<br><br>");
	document.write(y);
</script>

<br><br><br>
<script>
	function myFunction(name,job) {
		alert("Welcome " + name + ", the " + job + " " + carname);
	}
</script>
<!-- 这里的参数要用单引号 -->
<button onclick = "myFunction('Bill Gates','CEO')">点击这里</button>
<br><br><br>

<p id = "demo">Hello World!</p>
<script>
    /*
      js的返回值不需要标注类型 啥也不用标注
      return 也可以仅仅用来退出函数用
      rg:
      function changeName(a, b){
      	if (a > 5) {
      		return;
      	}
      	return a + b;
      }
    */
	function changeName(a, b) {
		return a * b;
	}
	document.getElementById("demo").innerHTML = changeName(3, 5);
</script>












