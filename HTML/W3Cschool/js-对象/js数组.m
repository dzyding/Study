/*
 1.创建数组
*/
 eg:
  var mayCars = new Array()
  myCars[0] = "Saab"
  myCars[1] = "Volvo"
  myCars[2] = "BMW"

  for (i = 0; i < myCars.length; i++) {
  	document.write(myCars[i] + "<br />")
  }


/*
 2.数组的合并
*/
 eg:
  var arr = new Array(3)
  arr[0] = "George"
  arr[1] = "John"
  arr[2] = "Thomas"

  var arr2 = new Array(3)
  arr2[0] = "James"
  arr2[1] = "Adrew"
  arr2[2] = "Martin"

  document.write(arr.concat(arr2))

/*
 3.用数组的元素组成字符串
*/
 eg:
  var arr = new Array(3)
  arr[0] = "George"
  arr[1] = "John"
  arr[2] = "Thomas"

  document.write(arr.join())   //George,John,Thomas   默认为,号分开
  document.write("<br />")
  document.write(arr.join("."))  //George.John.Thomas    


/*
 4.数组的排序
*/
 eg1:
  var arr = new Array(6)
  arr[0] = "George"
  arr[1] = "John"
  arr[2] = "Thomas"
  arr[3] = "James"
  arr[4] = "Adrew"
  arr[5] = "Martin"

  // var myCars = new Array("Saab","Volvo","BMW")

  document.write(arr + "<br />")   //George,John,Thomas,James,Adrew,Martin
  document.write(arr.sort())       //Adrew,George,James,John,Martin,Thomas
 
 eg2:
  function sortNumber(a, b) {
  	return a - b
  }

  var arr = new Array(6)
  arr[0] = "10"
  arr[1] = "5"
  arr[2] = "40"
  arr[3] = "25"
  arr[4] = "1000"
  arr[5] = "1"

  // var arr = new Array(1,5,30)

  document.write(arr + "<br />")          //10,5,40,25,1000,1
  document.write(arr.sort(sortNumber))    //1,5,10,25,40,1000 


















