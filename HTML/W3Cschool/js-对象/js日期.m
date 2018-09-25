/*
 处理日期和时间
*/
 
 1.使用 Date() 方法获取当前的日期
  eg:
   document.write(Date())  //Thu Dec 29 2016 15:29:12 GMT+0800 (CST) 

 2.getTime() 返回从1970年1月1日至今的毫秒数 
  eg:
   var d = new Date()
   document.write("从 1970/01/01 至今已过去 " + d.getTime() + "毫秒") //从 1970/01/01 至今已过去 1482996539640 毫秒 

 3.setFullYear()
   设置具体的日期
  eg:
   var d = new Date()
   d.setFullYear(1992,10,3)
   document.write(d)   //Tue Nov 03 1992 15:28:47 GMT+0800 (CST) 
   //!!! 这里的月份为 0 - 11  也就是设置7月就填6


 4.toUTCString
   将当前的日期转换成字符串
  eg:
   var d = new Date()
   document.write(d.toUTCString())  //Thu, 29 Dec 2016 07:27:53 GMT 

 5.getDay()
   使用getDay() 和数组来显示星期 而不仅仅是数字
  eg:
   var d = new Date()
   var weekday = new Array(7)
   weekday[0] = "星期日"
   weekday[1] = "星期一"
   weekday[2] = "星期二"
   weekday[3] = "星期三"
   weekday[4] = "星期四"
   weekday[5] = "星期五"
   weekday[6] = "星期六"

   document.write("今天是" + weekday[d.getDay()])  //d.getDay的结果为4  //今天是星期四 

 6.显示一个倒计时钟表
  function startTime() {
  	var today = new Date()
  	var h = today.getHours()
  	var m = today.getMinutes()
  	var s = today.getSeconds()
  	 // 小于10的数字补 "0"
  	m = checkTime(m)
  	s = checkTime(s)
  	document.getElementById('txt').innerHTML = h + ":" + m + ":" + s
  	t = setTimeout('startTime()', 500)  //0.5秒
  }

  function checkTime(i) {
  	if (i < 10) {
  		i = "0" + i
  		return i 
  	}
  }

  <body onload = "startTime()">
  <div id="txt"></div>

 7. 获取5天后的日期
  eg:
   var myDate = new Date()
   myDate.setDate(myDate.getDate() + 5)  //如果超过一个月的天数  会自动往上加

 8. 比较日期
  eg:
   var myDate = new Date()
   myDate.setFullYear(2016.10.11)

   var today = new Date()
   if (myDate > today) {
   	alert("Today is before 2016-11-11")
   }else {
   	alert("Today is after 2016-11-11")
   }




















