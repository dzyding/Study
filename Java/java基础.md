## 基本概念

1. Java 底层是 C++，而不是C。

2. 不支持多继承

3. 屏蔽了指针

4. Java 是运行在各操作系统对应的 Java 虚拟机（JVM）中的，所以它不是直接和操作系统打交道，所以它具有"可移植性"

5. 编译阶段将 .java 文件编译成 .class 文件，虚拟机运行的是 .class 文件（与 .java 完全无关，删了都行），如果改变了 .java 文件，需要重新编译 .class 文件

6. JDK，javac.exe 负责编译，java.exe 负责运行

	1. javac [文件名] // 编译

	2. java [类名(不带.class)] //运行

7. JDK（开发者工具）包含 JRE（运行时环境），JRE 包含 JVM（Java 虚拟机）

	如果有已经打包好的软件，可以只安装一个 JRE 就运行

## class 和 public class

1. 一个 java 源文件中可以定义多个 class

2. 一个 java 源文件中，public class 不是必须的

3. 编译的时，每个 class 会生成一个对应 .class 字节码文件

4. 一个 java 源文件当中定义 public class 的话，只能有一个，并且必须与文件名相同

5. 每一个 class 当中都可以编写 main 方法，未编写 main 方法的 class，编译完成之后执行会报错

## 基本数据类型

|基本数据类型|占用空间大小|
|----|----|
|byte|1|
|short|2|
|int|4|
|long|8|
|float|4|
|double|8|
|boolean|1|
|char|2|

## 成员变量的默认值

|数据类型|默认值|
|----|----|
|byte, short, int, long|0|
|float, double|0.0|
|boolean|false|
|char|\u0000|
|引用数据类型|null|

## 方法重载

相同方法名，不同参数的方法

```java
public int add(int a, int b) {
	return a + b;
}
public float add(float a, float b) {
	return a + b;
}
public double add(double a, double b) {
	return a + b;
}
```

相关条件（参数）： 

1. 数量不同  
2. 顺序不同  
3. 类型不同 

不相关条件：

1. 返回值类型  
2. 访问控制符 

## 类的定义

``` java
public class Student {
	int no;

	String name;

	int age;

	boolean sex;

	String addr;
}
```

## 各种内存

1. 方法区内存
	
	- 代码片段 (源代码) 

	- 静态变量 (static 变量)

2. 堆内存

	实例变量 (存的是所有创建出来的对象)

	垃圾回收主要针对的是堆内存，当实例不再有引用指向时，则自动销毁

3. 栈内存

	局部变量 (当前运行的方法，方法中涉及类的引用)

	栈内存是变幻的最频繁的

## 单例

```java
public class Singleton {
    // 在这里直接 new 出来，属于饿汉式，在 getInstance 方法中 new 出来属于懒汉式
    private static Singleton base = new Singleton();

    private Singleton() {}

    public static Singleton getInstance() {
        return base;
    }
}
```

## 抽象类

```java
// 抽象类的构造方法是给子类创建对象用的
public abstract class A {
    A() {
        System.out.println("A!...");
    }

    // 抽象类的方法不能有实现 (就是个接口？)
    public abstract void m1();

    public static void main(String[] args) {
        A a = new B();
        a.m1();
    }
}

class  B extends A {
    B() {
        // 父类的构造方法虽然调用了，但是并没有创建父类对象
        super();
        System.out.println("B!....");
    }

    // 继承自抽象类的类，必须覆盖或者重新
    public void m1() {
        System.out.println("B m1");
    }
}
```

## 接口

```java
/*
    1. 接口中只能出现：常量、抽象方法
    2. 接口中其实是一个特殊的抽象类，特殊在接口是完全抽象的
    3. 接口中没有构造方法，无法被实例化
    4. 接口和接口之间可以多继承
    5. 一个类可以实现多个接口（这里的"现实"类似"继承"）
    6. 一个非抽象的类实现接口，需要将接口中的所有方法"实现/重写/覆盖"
 */

public interface TestInterface {
    /*
    接口中所有变量都是默认 public static final
     */
    String SUCCESS = "success";
    public static final double PI = 3.14;

    /*
    接口中所有的方法都是默认 public abstract
     */
    public abstract void m1();

    void m2();
}

interface B {
    void m1();
}

interface C {
    void m2();
}

interface D {
    void m3();
}

interface E extends B, C, D {
    void m4();
}

class MyClass implements B, C {
    public void m1() {

    }

    public void m2() {

    }
}
```

## 判断是否属于某一个类

```java
class Star {

}

public boolean equals(Object obj) {
	if(obj instanceof Star) { // 如果是 Star 类型

	}
}
```

## 访问控制权限

|修饰符|类的内部|同一个包|子类|任何地方|
|----|----|----|----|----|
|private|Y|N|N|N|
|protected|Y|Y|Y|N|
|public|Y|Y|Y|Y|
|default|Y|Y|N|N|

## 匿名内部类

```java
public class Test {
	public static void t(CustomerService cs) {
		cs.logout();
	}

	public static void main(String[] args) {
		// 使用匿名内部类的方式执行 t 方法
		// 整个 CustomerService() { ... } 就是个匿名内部类
		t(new CustomerService(){
			public void logout() {
				System.out.println("exit");
			}
		});

		// 优点：少定义一个类
		// 缺点：无法重复使用
	}
}

interface CustomerService {
	void logout();
}
```

## 异常处理

```java
try { //捕获异常
    System.out.println("ABC");
}finally { // 不管是否捕获到异常，最后都会执行，一般会把资源释放写在里面
    System.out.println("finally");
}catch(ArithmeticException e) { // 捕获异常
    System.out.println(e);
}
```

```java
public static void main(String[] args) {
    int i = m1();
    System.out.println(i); // 10
}

public static int m1() {
    int i = 10;
    try {
        return i;
    }finally {
        i++;
        System.out.println(i); // 11
    }
}
```

## String StringBuilder StringBuffer

String 底层代码为一个用 final 修饰的 char 数组，意味着它通常是不可变的，虽然也可以进行字符串拼接，但是会创建出多个字符串，对内存并不友好  

StringBuffer StringBuilder 对于 char 的修饰符都没有使用 final 字段，执行拼接操作的时候会更友好  

1. StringBuffer 在拼接字符串时，使用了同步锁，安全性提高 

2. StringBuilder 未使用同步锁，故效率提高

## Collection<Interface> -> List<Interface>

Collection 只能存储引用类型，并且是单个存储 

List 有序可重复 

1. ArrayList
    
    ArrayList 底层采用的是数组存储元素的，所有 ArrayList 集合适合查询，不适合频繁的随机增删元素

2. LinkedList
    
    LinkedList 底层采用双向链表这种数据结构。链表适合频繁的增删元素，不适合查询操作

3. Vector (不常用)

    Vector 底层和 ArrayList 集合相同，但是 Vector 是线程安全的。不过效率较低。所以很少使用。

## 多线程

Java 使用抢占式调度模型：优先让优先级高的线程使用 CPU，如果线程的优先级相同，那么会随机选择一个，优先级高的线程获取的 CPU 时间片相对多一些。

线程的基本使用：

1. 方式一 

```java
public class ThreadTest {
    public static void main(String[] args) {
        Thread t = new Processor();
        // 设置最高优先级
        t.setPriority(Thread.MAX_PRIORITY);
        // 设置线程名字
        t.setName("t1");
        // 调用 start 方法开始运行线程，它将自动调用 run 方法
        t.start();
    }
}

class Processor extends Thread {
    public void run() {
        for (int i = 0; i < 30; i ++) {
            System.out.println("run --> " + i);
        }
    }
}
```

2. 方式二

```java
public class ThreadTest {
    public static void main(String[] args) {
        Thread t = new Thread(new Processor());
        // 调用 start 方法开始运行线程，它将自动调用 run 方法
        t.start();
    }
}

class Processor implements Runnable {
    public void run() {
        for (int i = 0; i < 30; i ++) {
            System.out.println("run --> " + i);
        }
    }
}
```






















