window.onload = function () {
	function $(id) {
		return document.getElementById(id);
	}
	var js_slider = $("js_slider");
	var slider_main_block = $("slider_main_block");
	var imgs = slider_main_block.children;
	var slider_ctrl = $("slider_ctrl");

	//生成pageController
	for (var i = 0; i < imgs.length; i++) {
		var span = document.createElement("span");
		span.className = "slider-ctrl-con";
		span.innerHTML = imgs.length - i;
		slider_ctrl.insertBefore(span,slider_ctrl.children[1]);
	}

	//添加完成以后 获取
	var spans = slider_ctrl.children;
	spans[1].setAttribute("class","slider-ctrl-con current");

	//得到大盒子的宽度 也就是后面动画走动的距离
	var scrollWidth = js_slider.clientWidth;	
	//默认第一张
	for (var i = 1; i < imgs.length; i++) {
		imgs[i].style.left = scrollWidth + "px";
	}

	var key = 0; //用来控制 当前需要显示的图片index
	for (var s in spans) {
		spans[s].onclick = function () {
			if (this.className == "slider-ctrl-prev") {
				dzy_attAnimate(imgs[key], {left: scrollWidth});
				//先-- 后判断
				--key < 0 ? key = imgs.length - 1 : key;
				imgs[key].style.left = -scrollWidth + "px";
				last_operate();
			}else if (this.className == "slider-ctrl-next") {
				autoplay();
			}else{
				if (this.className == "slider-ctrl-con current") {
					return;
				}
				clear_spanClass();
				this.setAttribute("class","slider-ctrl-con current");
				var index = parseInt(this.innerHTML);
				if (key < index - 1) {
					dzy_attAnimate(imgs[key], {left: -scrollWidth});
					imgs[index - 1].style.left = scrollWidth + "px";
				}else {
					dzy_attAnimate(imgs[key], {left: scrollWidth});
					imgs[index - 1].style.left = -scrollWidth + "px";
				}
				key = index - 1;
				dzy_attAnimate(imgs[key], {left: 0});
			}
		}
	}
	//清楚当前page
	function clear_spanClass() {
		for (var i = 1; i < spans.length - 1; i++) {
			spans[i].className = "slider-ctrl-con";
		}
	}
	//新图片的动画 page的更换
	function last_operate() {
		dzy_attAnimate(imgs[key], {left: 0});
		clear_spanClass();
		spans[key + 1].setAttribute("class","slider-ctrl-con current");
	}

	var timer = null;
	timer = setInterval(autoplay, 2000); //开启定时器
	function autoplay() {
		dzy_attAnimate(imgs[key], {left: -scrollWidth});
		//先++ 后判断
		++key > imgs.length - 1 ? key = 0 : key;
		imgs[key].style.left = scrollWidth + "px";
		last_operate();
	}

	js_slider.onmouseover = function () {
		clearInterval(timer);
	}
	js_slider.onmouseout = function () {
		clearInterval(timer);
		timer = setInterval(autoplay, 2000);
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
	},30);
}