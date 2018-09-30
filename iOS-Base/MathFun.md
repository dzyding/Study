## 1. 小数取整

````
  /**
    向上取整
    ceil(4.1) = 5.0
    ceil(4.9) = 5.0
   */

    public func ceil(_: Double) -> Double
````

````
  /**
    向下取整
    floor(4.1) = 4.0
    floor(4.9) = 4.0
  */

  public func floor(_: Double) -> Double
````

````
  /**
    最接近参数的整数 (如果有两个就取偶数)
    nearbyint(-6.5) = -6
    nearbyint(-5.5) = -6
    nearbyint(-4.5) = -4
    nearbyint(6.5)  = 6
    nearbyint(5.5)  = 6
    nearbyint(4.5)  = 4
   */

  public func nearbyint(_: Double) -> Double
````

````
  /**
    最接近参数的整数 (如果有两个就取偶数)
    rint(6.5) = 6.0
    rint(5.5) = 6.0
    rint(4.5) = 4.0
    rint(-6.5) = -6.0
    rint(-5.5) = -6.0
    rint(-4.5) = -4.0
    rint(5.112) = 5.0
   */

    public func rint(_: Double) -> Double


  /**
    和rint一样的，不过返回的是Int
   */

    public func lrint(_: Double) -> Int
````

````
  /**
    (其实就是四舍五入，只不过负数的情况是反过来的) (似乎这就是正常的四舍五入)
    > 0 满0.5 + 1
    < 0 满0.5 - 1
   */

    round(-6.5) = -7
    round(-5.5) = -6
    round(-4.5) = -5
    round(6.5)  = 7
    round(5.5)  = 6
    round(4.5)  = 5
      
    public func round(_: Double) -> Double

  /**
    和round一样，只不过返回的是整数
   */
    public func lround(_: Double) -> Int
````

## 2. 只保留小数整数部分

````
  /**
    直接去除数字的小数部分
   */
    trunc(-6.534) = -6
    trunc(4.34)   = 4

    public func trunc(_: Double) -> Double
````

## 3. 取模 取余

````
  /**
    取模
   */
    fmod(6, 2.1)    = 1.8
    fmod(0.6, 0.13) = 0.08
   
    public func fmod(_: Double, _: Double) -> Double
````

````
  /**
    取余 (正负取绝对值小的那个)
   */
    remainder(6, 1.8)      = 0.6
    remainder(0.6, 0.13)   = -0.05
   
    public func remainder(_: Double, _: Double) -> Double
````

````
  /**
    取余 (正负取绝对值小的那个)
    a为的是第一个数除以第二个数 四舍五入的值
   */
    var a: Int32
    remquo(20.1, 13, &a)// -5.9, a = 2
    remquo(20.1, 14, &a)// -7.9, a = 1
   
     public func remquo(_: Double, _: Double, _: UnsafeMutablePointer<Int32>!) -> Double
````

## 4. 其他

````
  /**
    以第二个参数的符号(正或负), 返回第一个参数
   */
    copysign(1.0, -3.2)//  -1.0
    copysign(1.0, 2.4 )//  1.0

    public func copysign(_: Double, _: Double) -> Double
````

````
  /**
    x = a - b <= 0 ? 0 : a - b
   */

    public func fdim(a: Double, b: Double) -> Double
     
  /**
    x = a >= b ? a : b
   */

    public func fmax(a: Double, b: Double) -> Double
     
  /**
    x = a <= b ? a : b
   */

    public func fmin(a: Double, b: Double) -> Double
     
  /**
    x = a * b + c
   */
    public func fma(a: Double, b: Double, c: Double) -> Double
````

````
  /**
  返回值为参数的小数部分
  整数部分通过指针存
  */
    eg:
      var mech: Double = 0
      let num = modf(3.123, &mech)
      //mech = 3.0  num = 0.123

  public func modf(_: Double, _: UnsafeMutablePointer<Double>!) -> Double
````

````
  //x的y次幂
  public func pow(x: Double, y: Double) -> Double
  //平方根
  public func sqrt(_: Double) -> Double

  //绝对值
  public func fabs(_: Double) -> Double
  //立方根
  public func cbrt(_: Double) -> Double
````

````
  /**
  x * (2的num次幂)
   */
    eg:
    ldexp(3.0, 3) = 24
    ldexp(3.0, 2) = 12

  public func ldexp(x: Double, num: Int32) -> Double
````

````
  /**
    m * 2^n = (输入值)
   */
  var n: Int32 = 0
  var m = frexp(16.400000, &n)
  n = 5  m = 0.5125
     
  16.4 = 0.5125 * (2^5) = 0.5125 * 32

  public func frexp(_: Double, _: UnsafeMutablePointer<Int32>!) -> Double
````

````
  /**
    直角三角形的斜边长
    a^2 + b^2 = c^2
    已知a，b 求c
   */

  public func hypot(_: Double, _: Double) -> Double
````

````
/**
  反三角函数
 */
  public func acos(_: Double) -> Double
  public func asin(_: Double) -> Double

  public func atan(_: Double) -> Double  
  反正切 (主值)，结果介于[-PI/2,PI/2]

  public func atan2(_: Double, _: Double) -> Double 
  反正切 (整圆值), 结果介于[-PI,PI]
````
     
````
 /**
  三角函数
  */
  public func cos(_: Double) -> Double
  public func sin(_: Double) -> Double
  public func tan(_: Double) -> Double
````
     
````
  /**
  反双曲三角函数
   */
  public func acosh(_: Double) -> Double
  public func asinh(_: Double) -> Double
  public func atanh(_: Double) -> Double
````

````
  /**
  双曲三角函数
  */
  public func cosh(_: Double) -> Double
  public func sinh(_: Double) -> Double
  public func tanh(_: Double) -> Double
````

````
  //e的n次幂
  public func exp(_: Double) -> Double
  //2的n次幂
  public func exp2(_: Double) -> Double
  //1.71828 的n次幂 (不知道这个数是干嘛的)
  public func expm1(_: Double) -> Double
````

````
  //e为底的对数
  public func log(_: Double) -> Double
  //10为底的对数
  public func log10(_: Double) -> Double
  //2为底的对数
  public func log2(_: Double) -> Double
````
