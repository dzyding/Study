///获取卷动区域大小
function dzy_scrollTop() {
	//这里必须写null 不然window.pageYOffset 刚打开界面的时候 永远等于0
	if (window.pageYOffset != null) {//判断ie9+ 和其他比较新的浏览器
		return {
			left: window.pageXOffset,
			top: window.pageYOffset
		}
	}else if (document.compatMode == "CSS1Compat"){ //已经申明<!DOCTYPE html>的浏览器
		return {
			left:document.documentElement.scrollLeft,
			top: document.documentElement.scrollTop
		}
	}else{
		return {
			left: document.body.scrollLeft,
			top:  document.body.scrollTop,
		}
	}
}

function $(id) {
	return document.getElementById(id);
}

function show(obj){
	obj.style.display = "block";
}

function hide(obj){
	obj.style.display = "none";
}

///获取网页可视区域的宽度
function dzy_clientWidth() {
	if (window.innerWidth != null) { //ie9 + 最新浏览器
		return {
			width: window.innerWidth,
			height: window.innerHeight
		}
	}else if(document.compatMode === "CSS1Compat") { // 标准浏览器 (有申明html头的)
		return {
			width: document.documentElement.clientWidth,
			height: document.documentElement.clientHeight,
		}
	}else {  //怪异浏览器
		return {
			width: document.body.clientWidth,
			height: document.body.clientHeight
		}
	}
}

//指定对象 的 指定属性
function dzy_getStyle(obj,attr) {
	if (obj.currentStyle) {	//ie等
		return obj.currentStyle[attr];
	}else { //标准浏览器 w3c
		return window.getComputedStyle(obj,null)[attr];
	}
}

//css属性动画
function dzy_attAnimate(obj, json, fn) {
	clearInterval(obj.timer);
	obj.timer = setInterval(function(){
		//用来判断是否停止定时器
		var flag = true;
		for (var attr in json) {
			//得到当前的样式
			var current = 0;
			if (attr == "opacity") {
				current = dzy_getStyle(obj,attr) * 100; //换成整数来进行计算
			}else {
				current = parseInt(dzy_getStyle(obj,attr));
			}
			//步长
			var step = (json[attr] - current) / 10; 
			//四舍五入
			step = step > 0 ? Math.ceil(step) : Math.floor(step);
			//结果
			if (attr == "opacity") { //如果是透明度属性 则不需要加px
				if ("opacity" in obj.style) { //判断是否支持opacity
					obj.style.opacity = (current + step) / 100;
				}else {	//ie6 7 8
					obj.style.filter = "alpha(opacity = " + (current + step) + ")";
				}
			}else if (attr == "zIndex") {
				obj.style.zIndex = json[attr];
			}else {
				obj.style[attr] = current + step + "px";
			}
			if (current != json[attr]) {
				//只要有一个不满足条件 则设置为false
				flag = false;
			}
		}
		if (flag) {
			clearInterval(obj.timer);
			if (fn) {
				fn();
			}
		}
	},10);
}