/*
 JavaScript 计时
*/
 通过使用JavaScript，我们有能力做到在一个设定的时间间隔之后来执行代码，而不是在函数被调用后立即执行。我们称之为计时事件。



/*
 简单的计时
*/
 eg1: //点击按钮后，在5秒后弹出一个警告框

 function timedMsg() {
 	var t = setTimeout("alert('5秒!')", 5000)
 }

 <input type = "button" value = "显示定时的警告框" onclick = "timedMsg()">


 eg2: //执行2秒 4秒 6秒的计时
 function timedText() {
 	var t1 = setTimeout("document.getElementById('txt').value = '2 秒'", 2000)
 	var t2 = setTimeout("document.getElementById('txt').value = '4 秒'", 4000)
 	var t3 = setTimeout("document.getElementById('txt').value = '6 秒'", 6000)
 }

 <input type = "button" value = "显示计时的文本" onclick = "timedText()">


/*
 在一个无穷循环中的计时事件
*/
 eg: //单击开始按钮后，程序开始从0以秒计时
 var c = 0
 var t
 function timedCount() {
 	document.getElementById('txt').value = c
 	c = c + 1
 	t = setTimeout("timedCount()", 1000)
 }

 <input type = "button" value = "开始计时!" onclick = "timedCount()">



/*
 带有停止按钮的无穷循环中的计时事件
*/
 eg:  //点击基数按钮后根据用户输入的数值开始倒计时，点击停止按钮停止计时
 function stopCount() {
 	c = 0
 	setTimeout("document.getElementById('txt').value = 0", 0)
 	clearTimeout(t)
 }
 
 <input type = "button" value = "停止计时!" onClick = "stopCount()">


/*
 使用计时事件制作的钟表
*/
 一个JavaScript 小时钟
 eg:
 function startTime() {
 	var today = new Date()
 	var h = today.getHours()
 	var m = today.getMinutes()
 	var s = today.getSeconds()
 	m = checkTime(m)
 	s = checkTime(s)
 	document.getElementById('txt').innerHTML = h + ":" + m + ":" + s
 	t = setTimeout('startTime()', 500)
 }

 function checkTime(i) {
 	if (i < 10) {
 		i = "0" + i
 	}
 	return i
 }
 
 <body onload = "startTime()">
 <div id = "txt"></div>





















