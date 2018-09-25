/*
 逻辑对象
*/
 Boolean (逻辑) 对象用于将非逻辑值转换为逻辑值 (true or false)
 eg:
  var b1 = new Boolean(0)           //false
  var b2 = new Boolean(1)           //true
  var b3 = new Boolean("")          //false
  var b4 = new Boolean(null)        //fasle 
  var b5 = new Boolean(NaN)         //fasle
  var b6 = new Boolean("false")     //true



/*
 算数对象 Math
*/
 执行普通的算数任务
 Math 对象提供多种计算数值类型和函数 无需在使用这个对象之前对它进行定义

  round 四舍五入
 eg:
  document.write(Math.round(0.60) + "<br />")  //1
  document.write(Math.round(0.50) + "<br />")  //1
  document.write(Math.round(0.49) + "<br />")  //0
  document.write(Math.round(-4.40) + "<br />") //4
  document.write(Math.round(-4.60))            //5

  random 随机 0 - 1
 eg:
  document.write(Math.random())  

  max 返回两个给定的数中较大的数
 eg:
  document.write(Math.max(5,7) + "<br />")   // 7
  document.write(Math.max(-3,-5) + "<br />") // -3
  document.write(Math.max(7.25,7.30))        // 7.3

  min 返回两个给定的数中较小的数

  floor() random()  随机数
 eg:
  document.write(Math.floor(Math.random() * 11))
/*
 JavaScript 支持的算数值
*/
  Math.E         // 常数
  Math.PI        // 圆周率
  Math.SQRT2     // 2的平方根
  Math.SQRT1_2   // 1/2的平方根
  Math.LN2       // 2的自然对数
  Math.LN10      // 10的自然对数
  Math.LOG2E     // 以2为底的e的对数
  Math.LOG10E    // 以10为底的e的对数
















