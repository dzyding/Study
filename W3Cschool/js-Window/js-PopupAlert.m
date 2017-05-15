/*
 JavaScript 消息框
*/
 JavaScript 中可以创建三种消息框: 警告框、确认框、提示框


/*
 警告框
*/
 警告框出现后，用户需要点击确定按钮才能继续进行操作
 eg:
  function disp_alert() {
  	alert("我是警告框!" + '\n' + "如何向警告框添加折行")
  }

  <input type = "button" onclick = "disp_alert()" value = "显示警告框">


/*
 确认框
*/
 确认框用于使用户可以体验或者接受某些信息
 当确认框出现后，用户需要点击确认或者取消按钮才能继续进行操作
 当用户点击确认，那么返回值为true。 点击取消，那么返回false。
 eg:
  function show_confirm() {
  	var r = confirm("Press a button!")
  	if (r == true){
  		alert("You pressed OK!")
  	}else {
  		alert("You pressed Cancel!")
  	}
  }
  <input type = "button" onclick = "show_confirm()" value = "Show a confirm box">


/*
 提示框
*/
 提示框经常用于提示用户在进入界面前输入某个值
 当提示框出现后，用户需要输入某个值，然后点击确认或者取消按钮才能继续操作
 如果用户点击确认，那么返回值为输入值。如果用户点击取消，那么返回值为null
 eg:
  function disp_prompt() {
  	var name = prompt("请输入您的名字", "Bill Gates")
  	if (name != null && name != ""){
  		document.write("您好! " + name + "今天过的怎么样?")
  	}
  }
  <input type = "button" onclick = "disp_prompt()" value = "显示提示框">