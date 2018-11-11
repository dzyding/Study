endl 的效果是结束当前行，并将设备关联的 **缓冲区** 内容显示到设备中。**调试程序的时候应该“一直”刷新流，确保清空了缓冲区，避免发生意外的崩溃**  

***

标准库定义的所有名字都在命名空间 std 中。  

***

## 读取数量不定的输入数据

```c++
#include <iostream>

int main(int argc, const char * argv[]) {
    //MacOS 中的文件结束符为 Ctrl+D 或者输入错误也就结束了循环
    int sum = 0, value = 0;
    std::cout << "begin" << std::endl;
    while (std::cin >> value) {
        sum += value;
    }
    std::cout << "Sum is: " << sum << std::endl;
    return 0;
}
```

***

倒入头文件  

- 包含来自标准库的头文件时，应该用 ( < > ) 包围头文件名  

- 对于补属于标准库的头文件，则使用 ( " " ) 包围 

***  

文件重定向 P45

***  

成员函数时定义为类的一部分的函数，有时也被称为 **方法（method）** 

***  

c++ 是一种静态数据类型语言，它的类型检查发生在编译时。

*** 

一个 char 的空间应该确保可以存放机器基本字符集中任意字符对应的数字值。也就是说，一个 char 的大小和一个机器字节一样。  

其他字符类型用于扩展字符集。   

wchar_t 类型用于确保可以存放机器最大扩展字符集中的任意一个字符。  

char16_t 和 char32_t 则为 Unicode（用于表示所有自然语言中字符的标准） 字符集服务。

***

一个字节为 8 比特，字为 32/64 比特。

***

关于无符号整型  

`2 的 32次方为 4294967296`

```c++
unsigned u = 10;
int i = -42;

//如果 int 占 32 位，输出 4294967296，也就是 4294967296 % 32
std::cout << u + i << std::endl;  
```

***

转义序列

\x 后紧跟 1 个或多个十六进制数字  // \x4d （字符 M）  

\ 后紧跟 1 个、2 个或 3 个八进制数字 // \40 （空格）  \12 （换行符）  

> 注意：如果反斜线 \ 后面跟着的八进制数字超过 3 个，只有前 3 个数字与 \ 构成转义序列。例如，“\1234” 表示 2 个字符，即八进制 123 对应的字符以及字符 4。
> 相反，\x 要用到后面跟着的所有数字，例如 “\x1234” 表示一个 16 位的字符，该字符由这 4 个十六进制的数所对应的比特唯一确定。因为大多数机器的 char 型数据占 8 位，所以上面这个例子可能会报错。  

*** 

## 指定字面值的类型  

**字符和字符串字面值**  

|前缀|含义|类型|
|----|----|----|
|u|Unicode 16 字符|char16_t|
|U|Unicode 32 字符|char32_t|
|L|宽字符|wchar_t|
|u8|UTF-8（仅用于字符串字面常量）|char|  

**整形字面值**  

|后缀|最小匹配类型|
|----|----|
|u or U|unsigned|
|l or L|long|
|ll or LL|long long|  

**浮点型字面值**  

|后缀|最小匹配类型|
|----|----|
|f or F|float|
|l or L|long double|

**布尔字面值：**true false  

**指针字面值：**nullptr   

***  

## 初始化 和 赋值

c ++ 中 **初始化**和**赋值** 不是一回事！！！  

初始化：创建变量时赋予其一个初始值  

赋值：把对象的当前值擦除，而以一个新值类替代  

C++ 语言定义了初始化的好几种不同形式。例如要想定义一个名为 units_sold 的 int 变量并初始化为 0，一下的 4 条语句都可以做到这一点：  

```c++
int units_sold = 0;
int units_sold = {0};
int units_sold{0};
int units_sold(0);
```

> 作为 C++11 新标准的一部分，用花括号来初始化变量得到了全面的应用。称为**列表初始化**。  

### 列表初始化

用于内置类型的变量时，这种初始化形式由一个重要的特点：如果我们使用列表初始化且初始化值存在丢失信息的风险，则编译器将报错：  

```c++
long double ld = 3.1415926536;
int a{ld}, b = {ld};	//错误：转换未执行，因为存在丢失信息的危险
int c(ld), d = ld;		//正确：转换执行，且确实丢失了部分值
```

***  

##分离式编译  

该机制允许程序分割为若干个文件，每个文件可被独立编译。  

为了支持分离式编译，C++ 语言将声明和定义区分开来。**声明（declaration）**使得名字为程序所知，一个文件如果想使用别处定义的名字则必须包含对那个名字的声明，关键字为 `extern`。而**定义（definition）**负责创建与名字关联的实体。  

```c++
extern int i;  //声明 i 而非定义 i
int j;		   //声明并定义 j
```  

若果要在多个文件中使用同一个变量，就必须将声明和定义分离。此时，变量的定义必须出现在且只能出现在一个文件中，而其他用到该变量的文件必须对其进行声明，却绝对不能重复定义。

***  

使用 `::` 符号显示的访问全局作用域。  

```c++
//全局变量 abc
int abc;

::abc //显示的访问全局变量，因为全局作用域本身并没有名字，所以作用域左侧为空。
```

***  

## 引用（别名）

定义引用时，程序把引用和它的初始值 **绑定（bind）** 在一起，而不是将初始值拷贝给引用。一旦初始化完成，引用将和它的初始值对象一直绑定在一起。  
引用即别名，为引用赋值，实际上是把值赋给了与引用绑定的对象。获取引用的值，实际上去获取了与引用绑定的对象的值。  

***

不能直接操作 void* 指针所指的对象。因为我们并不知道这个对象是什么类型。  

***  

```c++
int i = 42;
int *p;			//p 是一个 int 型指针
int *&r = p;	//r 是一个对指针 p 的引用

r = &i;			//r 引用了一个指针，因此给 r 赋值 &i 就是令 p 指向 i
*r = 0;			//解引用 r 得到 i，也就是 p 指向的对象，将 i 的值改为 0 
```

> 想要了解 r 的类型到底是什么，最简单的办法就是从右向左阅读 r 的定义。离变量名最近的符号（此例中 &r 的符号是 &）对变量的类型有最直接的影响，因此 r 是一个引用。声明符其余部分用以确定 r 引用的类型是什么，此例中的符号 * 说明 r 引用的是一个指针。最后，声明的基本数据类型部分指出 r 引用的是一个 int 指针。

***

## const 关键字

默认情况下，const 对象被设定为仅在文件内有效。当多个文件中出现了同名的 const 变量时，其实等同于在不同文件中分别定义了独立的变量。  

若想定义的 const 变量在文件间共享。则不管是声明还是定义都添加 extern 关键字，这样只需定义一次就可以了：  

```c++
// file_1.cc 定义并初始化了一个常量，该常量能被其他文件访问
extern const int bufSize = fcn();
// file_1.h 头文件
extern const int bufSize;  //与 file_1.cc 中定义的 bufSize 是同一个
```  

> 可以把引用绑定到 const 对象上，就像绑定到其他对象上一样。  
> 与普通引用不同的是，对常量的引用不能被用作修改它所绑定的对象！！

### 初始化和对 const 的引用 

```c++
int i = 42;					
const int &r1 = i;			//允许将 const int& 绑定到一个普通的 int 对象上
const int &r2 = 42;			//正确：r2 是一个常量引用
const int &r3 = r1 * 2;		//正确：r3 是一个常量引用
int &r4 = r1 * 2;			//错误：r4 是一个普通的非常量引	用 

//在这里，我们不能通过引用 r1 来改变 i 的值，因为 r1 是常量引用。
//但是可以直接通过 i 来改变 i 的值。同时 r1 的值也会跟着改变。
```

### const 指针

```c++
int errNumb = 0;				
int *const curErr = &errNumb;	// curErr 将一直指向 errNumb
const double pi = 3.14159;
const double *const pip = pi;	// pip 是一个指向常量对象的常量指针
```

> 要想弄清楚这些声明的含义，最行之有效的办法是从右向左读。此例中，离 curErr 最近的符号是 const，意味着 curErr 本身是一个常量对象，对象的类型由声明符的其余部分确定。声明符的下一个符号是 `*`，意思是 curErr 是一个常量指针。最后，该声明语句的基本数据类型部分确定了常量指针指向的是一个 int 对象。  

### 顶层，底层 const

```c++
int i = 0;
int *const p1 = &i;			//不能改变 p1 的值，这是一个顶层的 const
const int ci = 42;			//不能改变 ci 的值，这是一个顶层 const
const int *p2 = &ci;		//允许改变 p2 的值，这是一个底层 const
const int *const p3 = p2; 	//靠右的 const 是顶层 const，靠左的是底层 const
const int &r = ci;			//用于声明引用的 const 都是底层 const
```

执行拷贝操作时，  

顶层 const 不受什么影响。  

底层 const 的限制却不能忽视。当执行对象的拷贝操作时，拷入和拷出的对象必须具有相同的底层 const 资格，或者两个对象的数据类型必须能够转换。  

### constexpr
C++11 标准规定，允许将变量声明为 constexpr 类型，以便由编译器来验证变量的值是否是一个常量表达式。声明为 constexpr 的变量一定是一个常量，而且必须使用常量表示式初始化：  

> constexpr 为编译时求值。  

```c++
constexpr int mf = 20;  		// 20 是常量表达式
constexpr int limit = mf + 1;	// mf + 1 是常量表达式
constexpr int sz = size();		// 只有当 size 是一个 constexpr 函数时
								// 才是一条正确的声明语句
```

> 一般来说，如果你认定变量时一个常量表达式，那就把它声明称 constexpr 类型。

> 在 constexpr 声明中如果定义了一个指针，限定符 constexpr 仅对指针有效，与指针所指的对象无关。  

```c++
const int *p = nullptr;			//p 时一个指向整形常量的指针
constexpr int *q = nullptr;		//q 时一个指向整数的常量指针
```

> constexpr 把它所定义的对象置为了**顶层** const。

## 类型别名

传统的方法是使用关键字 `typedef`：  

```c++
typedef double wages;		//wages 是 double 的同义词
typedef wages base, *p;		//base 是 double 的同义词，p 是 dobule* 的同义词
```

C++11 中规定了一种新的方法，使用**别名声明（alias declaration）**来定义类型的别名：  

```c++
using SI = Sales_item;		// SI 是 Sales_item 的同义词
```

这种方法用关键字 using 作为别名声明的开始，后面紧跟别名和等号，其作用是把等号左侧的名字规定称等号右侧类型的别名。

### 指针、常量和类型别名 

```c++
typedef char *pstring;
const pstring cstr = 0;		// cstr 是指向 char 的常量指针
const pstring *ps;			// ps 是一个指针，它的对象是指向 char 的常量指针
```

> 遇到一条使用了类型别名的声明语句时，人们往往会错误地尝试把类型别名**替换**成它本来的样子，以理解该语句的含义：  

```c++
const char *cstr = 0; //是对 const pstring cstr 的错误理解
```

> 再强调一遍：这种理解是错误的。声明语句中用到 pstring 时，其基本数据类型时指针。可是用 char* 重写了声明语句后，数据类型就变成了 char，* 成为了声明符的一部分。这样改写的结果是，const char 成了基本数据类型。前后两种声明含义截然不同，前者声明了一个指向 char 的常量指针，改写后的形式则声明了一个指向 const char 的指针。

***

## auto 类型说明符（C++ 11）
它能让编译器替我们去分析表达式所属的类型。**使用 auto 定义的变量必须有初始值：**  

```c++
// 由 val1 和 val2 相加的结果可以推断出 item 的类型
auto item = val1 + val2; 
``` 

auto 也能在一条语句中声明多个变量，但是语句中所有变量的初始基本数据类型都必须一样：  

```c++
auto i = 0, *p = &i;		//正确： i 是整数、p 是整形指针
auto sz = 0, pi = 3.14;		//错误： sz 和 pi 的类型不一致	
```

### 复合类型、常量和 auto

编译器以**引用**对象的类型作为 auto 的类型：  

```c++
int i = 0, &r = i;
auto a = r;		// a 是一个整数
```  

auto 一般会忽略掉**顶层** const，同时底层 const 则会保留下来：  

```c++
const int ci = i, &cr = ci;
auto b = ci;		// b 是一个整数 (顶层的 const 特性被忽略掉了)
auto c = cr;		// c 是一个整数 (别名，顶层 const 被忽略)
auto d = &i;		// d 是一个整形指针 (整数的地址就是指向整数的指针)
auto e = &ci;		// e 是一个指向整数常量的指针 (对常量对象取地址是一种底层 const)
```

如果希望推断出 auto 类型是一个顶层 const，需要明确指出：  

```c++
const auto f = ci;	// f 为 const int
```

还可以将引用的类型设为 auto，此时原来的原始化规则仍然适用：  

```c++
auto &g = ci;			// g 是一个整形常量引用，绑定到 ci
auto &h = 42;			// 错误： 不能为非常量引用绑定字面值
const auto &j = 42;		// 正确： 可以为常量引用绑定字面值
```

设置一个类型为 auto 的引用时，初始值中的顶层常量属性仍然保留。和往常一样，如果我们给初始值绑定一个引用，则此时的常量就不是顶层常量了。

***

## decltype 类型指示符
选择并返回操作数的数据类型。在此过程中，编译器分析表达式并得到它的类型，却**不实际计算**表达式的值：  

```c++
decltype(f()) sum = x;  // sum 的类型就是函数 f 的返回类型
```

编译器**并不实际调用**函数 f，而是使用**假如**调用发生时 f 的返回值类型作为 sum 的类型。

如果 decltype 使用的表达式是一个变量，则 decltype 返回该变量的类型（包括顶层 const 和引用在内）：  

```c++
const int ci = 0，&cj = ci;
decltype(ci) x = 0;		// x 的类型是 const int
decltype(cj) y = x;		// y 的类型是 const int&, y 绑定到变量 x
decltype(cj) z;			// 错误：z 是一个引用，必须初始化
```

### decltype 和 引用

如果 decltype 使用的表达式不是一个变量，则 decltype 返回表达式**结果**对应的类型。  

```c++
// decltype 的结果可以是引用类型
int i = 42, *p = &i, &r = i;
decltype(r + 0) b;		// 正确：加法的结果是 int，因此 b 是一个（未初始化的）int
decltype(*p) c;			// 错误：*p 是 int&，所以 c 是 int&，必须初始化 
decltype(*p) c = i;		// 正确：c 是 i 的引用！！！（亲测）
```

因为 r 是一个引用，因此 decltype(r) 的结果是引用类型。如果想让结果类型是 r **所指**的类型，可以把 r 作为表达式的一部分，如 r + 0，显然这个表达式的结果将是一个具体值而非一个引用。  

另一方面，如果表达式的内容是解引用（ * ）操作，则 decltype 将得到引用类型。**正如我们所熟悉的那样，解引用指针可以得到指针所指的对象，而且还能给这个对象赋值。**

> p 是 c 的地址，(* p) 等同于 &c，(* p) 也就是引用。所以引用的本质其实就是地址。  

### 特别注意
对于 decltype 所用的表达式来说，如果使用的是一个不加括号的变量，则得到的结果就是该变量的类型；如果给变量**加上**了一层或多层括号，编译器就会把它当成是一个**表达式**。变量是一种可以作为赋值语句左值的特殊表达式，所以这样的 decltype 就会得到引用类型：

```c++
// decltype 的表达式如果是加上了括号的变量，结果将是引用
// 其实就是将变量整个作为了一种类型，而不再是变量所表示的类型
decltype((i)) d;	// 错误：d 是 int&，必须初始化
decltype(i) e;		// 正确：e 是一个（未初始化的）int
```

> decltype((variable)) （注意是双层括号）的结果永远是引用！！！而 decltype(variable) 结果只有当 variable 本身就是一个引用时才是引用。

***

## 自定义数据结构

```c++
struct Seles_data/*类名*/ {
    /*类体（可以为空）*/
    std::string bookNo;
    unsigned units_sold = 0;  //C++11 规定，可以初始化
    double revenue = 0.0;
};/*因为这里可以紧跟变量名，进行变量的声明，所以如果不声明变量的话必须加；*/

int main(int argc, const char * argv[]) {
    Seles_data data1, data2;
    double price = 0; //书的单价，用于计算销售收入
    std::cout << "请分别输入 ISBN、销售数量、单价" << std::endl;
    //读入第一笔交易：ISBN、销售数量、单价
    std::cin >> data1.bookNo >> data1.units_sold >> price;
    //计算销售收入
    data1.revenue = data1.units_sold * price;
    
    std::cout << "请分别输入 ISBN、销售数量、单价" << std::endl;
    std::cin >> data2.bookNo >> data2.units_sold >> price;
    data2.revenue = data2.units_sold * price;
    
    //输出两个对象的和
    if (data1.bookNo == data2.bookNo) {
        unsigned totalCnt = data1.units_sold + data2.units_sold;
        double totalRevenue = data1.revenue + data2.revenue;
        
        std::cout << data1.bookNo << " " <<totalCnt << " " <<totalRevenue << " ";
        
        if (totalCnt != 0) {
            std::cout << totalRevenue / totalCnt << std::endl;
        }else {
            std::cout << "(no sales)" << std::endl;
        }
        return 0;
    }else {
        std::cerr << "Data must refer to the same ISBN" << std::endl;
        return -1;
    }
}
```

***

## 预处理器 - 头文件保护符

```c++
#define 指令把一个名字设定为预处理变量
#ifdef  当且仅当变量已定义时为真
#ifndef 当且仅当变量为定位时为真
#endif	一旦 #ifdef 检查为真时，执行后续操作直到 #endif 为止

#ifndef SALES_DATA_H  //SALES_DATA_H 头文件保护符
#define SALES_DATA_H
#include <string>
struct Sales_data
{
	std::string bookNo;
	unsigned units_sold = 0;
	double revenue = 0.0;
};
#endif
```








