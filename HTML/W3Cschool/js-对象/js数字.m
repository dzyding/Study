JavaScript 只有一种数字类型
可以使用也可以不使用小数点来书写数字

eg:
 var pi = 3.14
 var x  = 34

 var y = 123e5
 var z = 123e-5

/*
 JavaScipt 不是类型语言。与许多其他编程语言不同，JavaScipt不定义不同类型的数字，比如长 短 证书等
 JavaScipt 中所有的数字都存储为  根为10的64位(8比特), 浮点数
*/


/*
 精度
*/
  整数(不使用小数点或指数计数法) 最多为15位
  小数的最大位数是17, 但是浮点运算并不总是 100% 准确

/*
 八进制和十六进制
*/
  前缀为0 则JavaScript会把数值常量解释为八进制 
  前缀为0和'x' 则解释为十六进制
  eg:
   var y = 0377
   var z = 0xFF


  // !!!  绝对不要在数字前面加零， 除非你要进行八进制转换


/*
 数字属性和方法
*/
  .MAX VALUE                  //可表示的最大的数
  .MIN VALUE                  //可表示的最小的数
  .NEGATIVE INFINITIVE        //负无穷大 溢出时返回该值
  .POSITIVE INFINITIVE        //正无穷大 溢出时返回该值
  .NaN                        //非数字值
  .prototype                  //是您有能力向对象添加属性和方法
  .constructor                //返回对创建此对象Number函数的引用

  方法:
  .toExponential()            //把对象的值转换为指数计数法
  .toFixed()                  //把数字转换为字符串 结果的小数点后有指定位数的数字
  .toPrecision()              //把数字格式化为指定的长度
  .toString()                 //把数字转换为字符串 使用指定的基数
  .valueOf()                  //返回一个Number 对象的基本数字值





