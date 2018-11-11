## using 声明

```c++
#include <iostream>
// using 声明，当我们使用名字 cin 时，从命名空间 std 中获取它
using std::cin; // 可以在程序的开始，把所有需要用到的标准库名字都用 using 表示出来

int main()
{
	int i;
	cin >> i;	// 正确：cin 和  std::cin 含义相同
	cout << i;  // 错误：没有对应的 using 声明，必须使用完整的名字
	std::cout << i; //正确：显示的从 std 中使用 cout
	return 0;
}
```

> 头文件中不应该包含 using 声明！！！

*** 

# 标准库类型 string

标准库类型 string 表示可变长的字符串序列，使用 string 类型必须首先包含 string 头文件。作为标准库的一部分，string 定义在命名空间 std 中。

## 1. 初始化

|方法名|作用|
|:---|:---|  
|string s1|默认初始化，s1 是一个空串|  
|string s2(s1)|s2 是 s1 的副本|  
|string s2 = s1|等价于 s2(s1)，s2 是 s1 的副本|  
|string s3("value")|s3 是字面值 "value" 的副本，**除了字面值最后的那个空字符外**|  
|string s3 = "value"|等价于 s3("value")，s3 是字面值 "value" 的副本|  
|string s4(n, 'c')|把s4 初始化为由连续 n 个字符 c 组成的串|  

eg: 

```c++
string s1;
string s2 = s1;
string s3 = "hiya";
string s4(10, 'c');
```

## 2. string 对象上的操作

|操作|意义|
|---|---|
|os << s|将 s 写到输出流 os 当中，返回 os|
|is >> s|从 is 中读取字符出串赋给 s，字符串以空白分割，返回 is|
|getline(is, s)|从 is 中读取一行赋给 s，返回 is|
|s.empty()|s 为空返回 true，否则返回 false|
|s.size()|返回 s 中字符的个数|
|s[n]|返回 s 中第 n 个字符的**引用**，位置 n 从 0 计起|
|s1 + s2|返回 s1 和 s2 链接后的结果|
|s1 = s2|用 s2 的副本代替 s1 中原来的字符|
|s1 == s2|如果 s1 和 s2 中所含的字符完全一样，则它们相等|
|s1 != s2|string 对象的相等性判断对字母的大小写敏感|
|<, <=, >, >=|利用字符在字典中的顺序进行比较，且对字母的大小写敏感|

### 读写 string 对象
可以使用 IO 操作符读写 string 对象：  

```c++
int main()
{
	string s;				// 空字符串
	cin >> s;				// 将 string 对象读入 s，遇到空白停止
							// 该操作会自动忽略开头的空白
	cout << s << endl;		// 输出 s
							// cout << s 返回 cout 所以可以连写 cout << s << c
	return 0;
}
```

### 读取未知数量的 string 对象

```c++
int main()
{
	string word;
	while (cin >> word)			// 遇到文件结束标记或非法输入，则停止
		cout << word << endl;
	return 0;
}
```

### 使用 getline 读取一整行
getline 函数的参数是一个输入流和一个 string 对象，函数从给定的输入流中读入内容，知道遇到换行符为止（注意换行符也被读进来了），然后把所读的内容存入到那个 string 对象中去（注意不存换行符），并返回流参数，所以同样可以用它的结果作为判断条件。  

```c++
int main()
{
	string line;
	while (getline(cin, line))
		cout << line << endl;
	return 0;
}
```

> 触发 getline 函数返回的那个换行符实际上被丢弃掉了！！！

### string::size_type 类型
size 函数返回的并不是一个 int 或者 unsigned。而是 string::size_type。它属于 string 的**配套**类型。配套类型体现了标准库类型与机器无关的特性。

> 由于 size 函数返回的必定是一个无符号整型数，所以使用 size 函数的时候就不要使用 int 了，这样可以避免混用 int 和 unsigned 可能带来的问题。

### 比较

1. 如果两个 string 对象的长度不同，并且较短的 string 对象的每个字符都与较长 string 对象**对应位置上的字符相同**，就说较短 string 对象**小于**较长 string 对象。  

2. 如果两个 string 对象在某些对应的位置上不一致，则 string 对象比较的结果其实是 string 对象中第一对相异字符比较的结果。  

```c++
string str = "Hello";
string phrase = "Hello World";
string slang = "Hiya";

// str < phrase
// slang > str; slang > phrase
```

### 字面值和 string 对象相加

> string 对象支持使用 + 运算符来连接两个字符串，用以生成一个新的 string。

标准库允许把字符字面值和字符串字面值转换成 string，所以在需要 string 对象的地方就可以用这两种字面值来替代。  

> 当把 string 对象和字符字面值及字符串字面值混在一条语句中使用时，必须确保每个 + 两侧的运算对象至少有一个是 string。  

```c++
string s4 = s1 + ",";  //正确
string s5 = "hello" + ",";  //错误
string s6 = "hello" + "," + s1; //错误
string s7 = s1 + "hello" + ","  //正确
								//相当于 (s1 + "hello") + ","
```

> 因为某些历史原因，也为了与 C 兼容，所以 C++标准库类型 string 与字符串字面量是**不同**的类型。

## 3. 处理 string 对象中的字符

cctype 头文件中的函数：  

|函数名|作用|
|---|---|
|isalnum(c)|当 c 是字母或数字时为真|
|isalpha(c)|当 c 是字母时为真|
|iscntrl(c)|当 c 是控制字符时为真|
|isdigit(c)|当 c 是数字时为真|
|isgraph(c)|当 c 不是空格但可打印时为真|
|islower(c)|当 c 是小写字母时为真|
|isprint(c)|当 c 是可打印字符时为真（即 c 是空格或 c 具有可视形式）|
|ispunct(c)|当 c 是标点符号时为真（即 c 不是控制字符、数字、字母、可打印空白中的一种）|
|isspace(c)|当 c 是空白时为真（即 c 是空格、横向制表符、纵向制表符、回车符、换行符、进纸符中的一种）|
|isupper(c)|当 c 是大写字母时为真|
|isxdigit(c)|当 c 是十六进制数时为真|
|tolower(c)|如果 c 是大写字母，输出对应的小写字母；否则原样输出 c|
|toupper(c)|如果 c 是小写字母，输出对应的大写字母；否则原样输出 c|

> 建议使用 C++ 版本的 C 标准库头文件  
>  
> C++ 兼容了 C 语言的标准库。C 语言的头文件形如 name.h，C++ 则将这些文件命名为 cname。即去掉了 .h 后缀，而在文件名 name 之前添加了字母 c。  
>
> 因此 cctype 头文件 和 ctype.h 头文件的内容是一样的。特别的，在名为 cname 的头文件中定义的名字从属于命名空间 std，而定义在名为 .h 的文件中则不然。  

### 遍历

```c++
string s("Hello World!!!");
for (auto &c : s)
	c = toupper(c);	// 因为 c 是引用，因此赋值语句将改变 s 中的字符的值
					// 居然可以在遍历的过程中改变 s ?
cout << s << endl;
```

### 只处理一部分字符

> C++ 标准库中的 string，支持**下标运算符 []**，并返回该位置上字符的**引用**。又是引用，居然不是拷贝。

```c++
string s("some string");
if (!s.empty())
{
	s[0] = toupper((s[0]));

	// 输出 s 结果为 Some string 直接改变了 s !!!
}
```

### 使用下标执行迭代

```c++
for(decltype(s.size()) index = 0;
	index != s.size() && !isspace(s[index]); ++index )
	s[index] = toupper(s[index]); //将当前字符改成大写形式
```

### 例子

```c++
int main(int argc, const char * argv[]) {
    std::string s("some string");
    
    for (auto &c : s) {			//范围循环
        c = 'x';
    }
    
    decltype(s.size()) index = 0;
    while (index < s.size()) {		//while循环
        auto &c = s[index];
        c = 'x';
        index += 1;
    }
    
    for (decltype(s.size()) index = 0; index < s.size(); index ++) 
    	{	//常规for循环
        auto &c = s[index];
        if (std::isspace(c))
            continue;
        c = 'x';
    }
    std::cout << s << std::endl;
    return 0;
}
```

***

# 标准库类型 vector

使用时记得倒入头文件：  

```
#include <vector>
```

vector 能容纳绝大多数类型的**对象**作为其元素，但是因为**引用**不是对象，所以不存在容纳引用的 vector。

```c++
//声明一个容纳 int 类型的 vector：
vector<int> ivec;

//声明一个容纳 vector<int> 类型的 vector：
vector<vector<int>> ivec; 
```

> vector<vector<int>> ivec; 是 C++11 中的标准。在老式的编译器中，你可能需要写成 vector<vector<int> >。注意最后那个**空格**是必须的！！！ 

## 1. 定义和初始化 vector 对象

|初始化方法|解释|
|----|----|
|vector<T> v1|v1 是一个空 vector，它潜在的元素是 T 类型的，执行默认初始化|
|vector<T> v2(v1)|v2 中包含有 v1 所有元素的副本|
|vector<T> v2 = v1|等价于 v2(v1)|
|vector<T> v3(n, val)|v3 包含了 n 个重复的元素，每个元素的值都是 val|
|vector<T> v4(n)|v4 包含了 n 个重复地执行了值初始化的对象|
|vector<T> v5{a,b,c...}|v5 包含了初始值个数的元素，每个元素被赋予相应的初始值|
|vector<T> v5 = {a,b,c...}|等价于 v5{a,b,c...}|

### 值初始化

```c++
vector<int> ivec(10);		// 10 个元素，每个都初始化为 0
vector<string> svec<10>;	// 10 个元素，每个都是空的 string 对象
```

> 这种初始化方式有个限制：容纳的对象必须支持默认初始化！！！

### 列表初始化还是元素数量？

默认情况下，**圆括号**提供的值是用来构造 vector 对象的。**花括号**表述成我们想列表初始化该 vector 对象。

```c++
vector<int> v1(10);		// v1 有 10 个元素，每个都是 0
vector<int> v2{10};		// v2 有 1 个元素，其值为 10
vector<int> v3(10, 1);	// v3 有 10 个元素，每个都是 1
vector<int> v4{10, 1};	// v4 有 2 个元素，值分别是 10 和 1
```

但是也有特殊情况（并不推荐这样使用，难得理解）：想要列表初始化 vector 对象，花括号里的值必须与元素类型相同。当类型不同，**确认无法**执行列表初始化后，编译器会**尝试**用默认值初始化 vector 对象。 

```c++
vector<string> v7{10};			// v7 有 10 个默认初始化的元素
vector<string> v8{10, "hi"};	// v8 有 10 个值为 "hi" 的元素
```

## 2. 向 vector 对象中添加元素

`push_back` 方法，负责把一个值当成 vector 对象的尾元素“压到（push）”vector对象的“尾端（back）”。例如：  

```c++
vector<int>v2;
for (int i = 0; i != 100; ++i)
{
	v2.push_back(i);
}
```

> 既然 vector 对象能高效的增长，那么在定义 vector 对象的时候设定其大小就没什么必要了，事实上如果这么做性能可能更差。 

## 3. 其他 vector 操作

|操作|说明|
|----|----|
|v.empty()|判断是否为空|
|v.size()|获取大小|
|v.push_back(t)|向尾端添加一个值为 t 的元素|
|v[n]|返回 v 中的第 n 个元素的**引用**|
|v1 = v2|拷贝替换|
|v1 = {a,b,c... }|用列表中元素的拷贝替换 v1 中的元素|
|v1 == v2|元素数量相同，且对应位置的值相同|
|v1 != v2||
|<, <=, >, >=|比较|

> `size()` 方法返回的类型为 `vector<T>::size_type`，这里必须指定类型。而不是 vectoe::size_type！！！

> 比较：**只有当元素的值可比较时，vector 对象才能被比较。**当各位置元素的值存在不一样时，比较的是第一对相异元素值的大小。

### 索引

```c++
vector<unsigned> scores(10, 0);
unsigned grade;
while (cin >> grade) {
	if (grade <= 100) 
		++scores[grade/10];
}
```

> 不能用下标形式添加元素，下标运算符只能用于访问已存在的元素。

### 一个简单练习

```c++
// 3.17
#include <iostream>
#include <string>
#include <vector>

using namespace std;

int main(int argc, const char * argv[]) {
    vector<string> svec;
    string temp;
    cout << "请开始输入" << endl;
    while (cin >> temp) {
        for (auto &c : temp) {
            c = toupper(c);
        }
        svec.push_back(temp);
    }
    for (decltype(svec.size()) index = 0; index < svec.size(); index ++) {
        cout << svec[index] << endl;
    }
    return 0;
}
```

***

# 迭代器介绍

除了 vector、string 之外，标准库还定义了其他几种容器。所有的标准库容器都可以使用迭代器，但是其中只有少数几种才同时支持下标运算符。

> 严格来说，string 对象不属于容器类型，但是 string 支持很多与容器类型类似的操作。

类似于指针类型，迭代器也提供了对对象的间接访问。

## 1. 使用迭代器

和指针不一样的是，获取迭代器不是使用取地址符，有迭代器的类型同时拥有返回迭代器的成员（方法或类型）。比如，这些类型都拥有名为 `begin` 和 `end` 的成员。

```
// b 表示 v 的第一个元素，e 表示 v 尾元素的下一个位置
auto b = v.begin(), e = v.end();
```

> 请注意这里返回的是尾元素的**下一个**位置，也就是说，该迭代器指示的是容器的一个本不存在的“尾后（off the end）”元素。

### 迭代器运算符

|运算符|含义|
|----|----|
|*iter|返回迭代器 iter 所指元素的引用|
|iter->mem|解引用 iter 并获取该元素名为 mem 的成员，等价于 (*iter).mem|
|++iter|令 iter 指示容器中的下一个元素|
|--iter|令 iter 指示容器中的上一个元素|
|iter1 == iter2|判断两个迭代器是否相等（不相等），如果两个迭代器指示的是同一个元素或者它们是同一个容器的尾后迭代器，则相等|
|iter1 != iter2|反之，不相等|

```c++
string s("some string");
if (s.begin() != s.end()) //确保 s 非空
{
	auto it = s.begin();
	*it = toupper(*it);	//将当前字符改成大写形式
}
```

### 将迭代器从一个元素移动到另一个元素上

eg: 把 string 对象中第一个单词改写为大写形式。 

```c++
for(auto it = s.begin(); it != s.end() && !isspace(*it); ++it)
	*it = toupper(*it);
```

> 也许你会对 for 循环中使用 != 而非 < 进行判断有点儿奇怪。C++ 程序员习惯性的使用 !=，其原因和他们更愿意使用迭代器而非下标的原因一样：因为这种编程风格在标准库提供的所有容器上都有效。
>
> 之前有说过，只有 string 和 vector 等一些标准库类型有下标运算符，而并非全部如此。与之类似，所有标准库容器的迭代器都定义了 == 和 !=，但是它们中的大多数都没有定义 < 运算符。因此，只要我们养成使用迭代器和 != 的习惯，就不用太在意用的到底是哪种容器类型。

### 迭代器类型

那些拥有迭代器的标准库类型使用 iterator 和 const_iterator 来表示迭代器的类型：  

```c++
vector<int>::iterator it;	// it 能读取 vector<int> 的元素
string::iterator it2;		// it2 能读写 string 对象中的字符

vector<int>::const_iterator it3;	// it3 只能读元素，不能写元素
string::const_iterator it4;			// it4 只能读字符，不能写字符
```

**如果 vector 或 string 对象是一个常量，则只能使用 const_iterator。**  

> 迭代器这个名词有三种不同的含义：可能是迭代器概念本身，也可能是指容器定义的迭代器类型，还可能是指某个迭代器对象。  
>
> 重点是理解存在一组概念上相关的类型，我们认定某个类型是迭代器当且仅当它支持一套操作，这套操作使得我们能访问容器的元素或者从某个元素移动到另一个元素。  
>
> 每个容器定义了一个名为 iterator 的类型，该类型支持迭代器概念所规定的一套操作。

### cbegin 和 cend

C++11 新标准引入了两个新函数，分别是 cbegin 和 cend。无论 vector 对象（或者 string 对象）本身是否为常量，它们的返回值都是 const_iterator。

```
vector<int> v;
auto it3 = v.cbegin(); // it3 的类型是 vector<int>::const_iterator
```

### 结合解引用和成员访问操作

```c++
vector<int> ivec{1,3,4,6,7};
auto it = ivec.cbegin();

// (*it).empty()  等价于  it->empty()
```

`->` 运算符把解引用和成员访问两个操作结合在一起。

> 通过迭代器访问容器对应的成员，使用的是 * 解引用符。

### 简单的例子

```c++
#include <iostream>
#include <string>
#include <vector>

using namespace std;

int main(int argc, const char * argv[]) {
    vector<string> svec;
    string temp;
    cout << "请开始输入" << endl;
    while (cin >> temp) {
        for (auto it = temp.begin(); it != temp.end(); it ++) {
            (*it) = toupper(*it);
        }
        svec.push_back(temp);
    }
    for(auto it = svec.cbegin(); it != svec.cend() && !it->empty(); it ++)
        cout << *it << endl;
    return 0;
}
```

## 2. 迭代器运算

|运算符|含义|
|----|----|
|iter + n|得到一个**前**移若干个元素的新迭代器|
|iter - n|得到一个**后**移若干个元素的新迭代器|
|iter += n|iter = iter + n|
|iter -= n|iter = iter - n|
|>、>=、<、<=||

### 迭代器的算术运算

对迭代器进行 + - 运算，也就是向前或向后移动迭代器。- 运算符得到的是两个迭代器之间的距离。所有距离指的是右侧的迭代器向前移动多少位置就能追上左侧的迭代器，其类型是名为 `difference_type` 的带符号整型数。

### 经典的二分算法

```c++
#include <iostream>
#include <string>
#include <vector>

using namespace std;

int main(int argc, const char * argv[]) {
    vector<string> svec;
    string temp;
    cout << "请开始输入" << endl;
    while (cin >> temp) {
        svec.push_back(temp);
    }
    
    auto beg = svec.begin(), end = svec.end();
    auto mid = svec.begin() + (end - beg) / 2;
    while (mid != end && *mid != "f") {
        if ("f" < *mid) {
            end = mid;
        }else {
            beg = mid + 1;
        }
        mid = beg + (end - beg) / 2;
    }
    cout << *mid << endl;
    return 0;
}
```

***

# 数组

与标准库类型 vector 类似。区别为：**数组的大小确定不变，因此不能随意向数组中增加元素。**

> 如果不清楚元素的确切个数，请使用 vector

## 1. 定义和初始化内置数组

数组的声明形如 `a[d]`，其中 a 是数组的名字，d 是数组的维度。**维度必须大于 0，切必须是一个常量表达式**：  

```c++
unsigned cnt = 42;				//不是常量表达式
constexpr unsigned sz = 42;		//常量表达式
int arr[10];					//含有 10 个整数的数组
int *parr[sz];					//含有 42 个整型指针的数组
string bad[cnt];				//错误：cnt 不是常量表达式
string strs[get_size()];		//当 get_size 是 constexpr 时正确；否则错误
```

### 显示初始化数组元素

使用列表进行初始化时，允许忽略数组的维度。在声明时没有指明维度，编译器会根据初始值的数量计算并推测出来；相反，如果指明了维度，那么初始值的总数量不应该超出指定大小。如果维度比提供的初始值数量大，则剩下的元素被初始化成默认值：  

```c++
const unsigned sz = 3;			
int a1[sz] = {0, 1, 2};			// 含有 3 个元素的数组
int a2[] = {0, 1 , 2};			// 维度是 3 的数组
int a3[5] = {0, 1, 2};			// 等价于 a3[] = {0, 1, 2, 0, 0}
string a4[3] = {"hi", "bye"};	// 等价于 a4[] = {"hi", "bye", ""}
int a5[2] = {0, 1, 2};			// 错误：初始值过多
```

### 字符数组的特殊性

字符数组有一种额外的初始化形式，我们可以用字符串字面值对此类数组初始化。

> 当使用这种方式时，一定要注意字符串字面值的结尾处还有一个空字符。 `'\0'` 。并且其会占用数组的一个维度。

```c++
char a1[] = {'C', '+', '+'};// 列表初始化，没有空字符
							// 并不是字符串初始化，所有可以不包含空字符

char a2[] = {'C', '+', '+', '\0'};	// 列表初始化，含有显式的空字符
char a3[] = "C++";					// 自动添加表示字符串结束的空字符
const char a4[6] = "Daniel";		// 错误：没有空间可存放空字符！
```

### 不允许拷贝和赋值

不能将数组的内容拷贝给其他数组作为其初始值，不能用数组为其他数组赋值：

```c++
int a[] = {0, 1, 2};
int a2[] = a;		// 错误：不允许使用一个数组初始化另一个数组
a2 = a;				// 错误：不能把一个数组直接赋值给另一个数组
```

> 某些编译器支持数组的赋值，即**编译器扩展**。但是一般不支持这么做，这样写出的别的编译环境中可能得不到正常执行。

### 理解复杂的数组声明

```c++
int *ptrs[10];				// 含有 10 个 整形指针 的数组
int &refs[10] = /* ? */;	// 错误：不存在引用的数组
int (*Parray)[10] = &arr;	// Parray 指向一个含有 10 个整数的数组
int (*arrRef)[10] = arr;	// arrRef 引用一个含有 10 个整数的数组
int *(&arry)[10]  =ptrs;	// arry 是数组的引用，该数组含有 10 个指针
```

**string 默认初始化为 ""，int 默认初始化为 0。**

> 有括号包起来的，从内向外理解会好一些。

## 2. 访问数组元素

数组的下标类型为 `size_t` 类型。定义在 `cstddef` 头文件中，对应 C 标准库的 `stddef.h`。

```c++
for (auto i : scores)
	cout << i << " ";
cout << endl;
```

## 3. 指针和数组

指针和数组有非常紧密的联系。使用数组的时候编译器一般都会把它转换成指针。

```c++
string nums[] = {"one", "two", "three"};	// 数组的元素是 string 对象

string *p = *nums[0];	// p 指向 nums 的第一个元素

string *p2 = nums;		// p2 指向 nums 的首元素 
						// 等价于 p2 = &nums[0] （就和 C 语言一样）
```

由上可知，在一些情况下数组的操作实际上是指针的操作。因此会产生一些影响，比如 auto 推断得到的类型是指针而非数组：  

```c++
int ia[] = {0,1,2,3,4,5,6,7};	// ia 是一个含有 10 个整数的数组
auto ia2(ia);			// ia2 是一个整型指针，指向 ia 的第一个元素
ia2 = 42;				// 错误：ia2 是一个指针，不能用 int 赋值
```

尽管 ia 是一个由 10 个整数构成的数组，但当使用 ia 作为初始值时，编译器实际执行的初始化过程类似于下面的形式：  

```c++
auto ia2(&ia[0]);	// 显然 ia2 的类型是 int*
```

必须指出的是，当使用  decltype 关键字时，上述转换**不会**发生，`decltype(ia)` 返回的类型是由 10 个整数构成的数组：  

```c++
// ia3 是一个含有 10 个整数的数组
decltype(ia) ia3 = {0,1,2,3,4,5,6,7,8};
ia3 = p;		// 错误：不能用整形指针给数组赋值
ia3[4] = i;		// 正确：把 i 的值赋给 ia3 的一个元素
```

### 标准库函数 begin 和 end

由于数组不是类类型，因此其没有成员函数，也就没有能够直接获取其尾指针的成员函数。通过计算来获取尾指针的方式极易出错，因此 C++11 新标准引入了两个名字 begin 和 end 的函数。  

正确的使用形式是将数组作为它们的参数：  

```c++
int ia[] = {0,1,2,3,4,5,6,7,8};
int *beg = begin(ia2);		// 首元素指针
int *end = end(ia);			// 尾元素的下一位置的指针 （尾后指针）
```

> 这两个函数定义在 iterator 头文件中！！

### 指针运算

两个指针相减的结果是它们之间的距离。参与运算的两个指针**必须指向同一个数组中的元素**：  

```c++
auto n = end(arr) - begin(arr);	// n 的值是 5，也就是 arr 中元素的数量
```

两个指针相减的结果的类型是一种名为 `ptrdiff_t` 的标准库类型，和 `size_t` 一样，定义在 `cstddef` 头文件中。其是一个带符号类型。  

### 解引用和指针运算的交互

```c++
int ia[] = {0,2,4,6,8};
int last = *(ia + 4);		// 正确：把 last 初始化成 8，也就是 ia[4]

last = *ia + 4;	// 正确：  last = ia[0] + 4， 也就是 0 + 4 = 4
```

### 下标和指针

```c++
int ia[] = {0,2,4,6,8};

int i = ia[2];	// ia 转换成指向数组首元素的指针
				// ia[2] 得到 (ia + 2) 所指的元素
int *p = ia;	// p 指向 ia 的首元素
i = *(p + 2);	// 等价于 i = ia[2]

// 只要指针指向的是数组中的元素，都可以执行下标运算：  
int *p = &ia[2];	// p 指向索引为 2 的元素
int j = p[1];		// p[1] 等价于 *(p + 1)，也就是 ia[3] 表示的那个元素
int k = p[-2];		// p[-2] 是 ia[0] 表示的那个首元素
```

> 虽然标准库类型 string 和 vector 也能执行下标运算，但是数组和它们相比还是有所不同。标准库类型限定使用的下标**必须是无符号类型**，而内置的下标运算**无此要求**。内置的下标运算可以处理负值。

## 4. C 风格字符串















