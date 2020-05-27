Java DataBase Connectivity（Java 语言连接数据库）

它是 SUN 公司制定的一套接口（interface），接口都有**调用者**和**实现者**。

它的实现者是各大数据库厂家。

面向接口调用、面向接口写实现类，这都属于面向接口编程。

> 为什么要面向接口编程？
> 
> 解耦合：降低程序的耦合度，提高程序的扩展力。
> 
> 多态机制就是非常典型的：面向抽象编程。（不要面向具体编程）

## JDBC 编程六步

1. 注册驱动

	告诉 Java 程序，即将要连接的是那个品牌的数据库

2. 获取连接

	表示 JVM 的进程和数据库之间的通道打开了，这个属于进程之间的通信，重量级，使用完之后一点要关闭

3. 获取数据库对象

	专门执行 sql 语句的对象

4. 执行 SQL 语句

	DQL DML

5. 处理查询结果

	只有当第四部执行的是 select 语句的时候，才有第五步处理查询结果集

6. 释放资源

	使用完资源之后一定要关闭资源。 Java 和数据库属于进程间的通信，开启之后一定要关闭

## Demo 请看 resources 下 JDBC 文件夹

1. JDBCTest01、02
	
	最基本的 Demo

2. JDBCTest03

	通过 Class.forName 来注册驱动

3. JDBCTest04

	通过配置文件编写程序

4. JDBCTest05
	
	查询语句及查询结果处理

## SQL 注入

假如登录的 sql 语句

```java
String sql = "select * from t_user where loginName = '" + loginName + "' and loginPwd = '" + loginPwd + "'";
```

用户输入：

```
loginName: fdsa
loginPwd: fdsa' or '1' = '1
```

最终登录的 sql 就变成了

```java
String sql = "select * from t_user where loginName = 'fdsa' and loginPwd = 'fdsa' or '1' = '1'";
```

此时 `where` 后面的判断语句成了 `loginName = 'fdsa' and loginPwd = 'fdsa'` **or** `'1' = '1'`，但是后者是恒为 `true` 的，所以始终都可以查出数据。

> 根本原因
> 
> 用户输入的信息中含有 sql 语句的关键字，并且这些关键字参与 sql 语句的编译过程。导致 sql 语句的原意被扭曲，进而达到了 sql 注入

## SQL 注入的解决方案

核心逻辑：

```
只要用户提供的信息不参与 SQL 语句的编译过程，问题就解决了。
即使用户提供的信息中包含 SQL 语句的关键字，但是没有参与编译，则不会起作用。
要想用户信息不参与 SQL 语句的编译，那么必须使用 java.sql.PreparedStatement

PreparedStatement 接口继承了 java.sql.Statement
PreparedStatement 是属于预编译的数据库操作对象
PreparedStatement 的原理是：预先对 SQL 语句的框架进行编译，然后再给 SQL 语句传 “值”
```

> 参考 `JDBCTest06`

`PreparedStatement` 和 `Statement` 的对比：

1. `Statement` 存在 sql 注入问题，`PreparedStatement` 解决了 SQL 注入的问题

2. 由于系统执行 sql 语句，若是完全相同的语句执行多次，只会对第一次进行编译。`Statement` 由于每次的参数不一样，所以每次都需要重新编译。`PreparedStatement` 由于语句是框架是固定的，只需要更改参数，所以它只编译一次，效率会更高

3. `PreparedStatement` 会在编译阶段做类型的安全检查

## JDBC 的事物机制

默认：

```
JDBC 中的事务默认是自动提交的。

只要执行任意一条 DML 语句，则自动提交一次。

但是在实际开发中，通常都是 N 条 DML 语句共同联合才能完成的。所以在需要的时候通常我们会改成手动提交
```

> 参考 `JDBCTest07`

## JDBC的模糊查询和工具类

> 参考 `JDBCTest08`


## 悲观锁、乐观锁

- 悲观锁（行级锁：select 后面添加 for update）

事务必须排队执行。数据锁住了，不允许并发

eg:

```sql
select ename, sal from emp where ename = 'Jack' for update;
```

- 乐观锁

支持并发，事务也不需要排队，只不过需要一个**版本号**。若是某一个事务修改数据时，发现当行数据已经了更新的版本，则操作失败，事务自动回滚。





















