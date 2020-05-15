<!-- mysql -uroot -pDing52150021 -->

## 导航

1. <a href="#1">sql语句分类</a> 

2. <a href="#2">基础指令</a> 

3. <a href="#3">常用命令</a> 

4. <a href="#4">查询</a> 
	- <a href="#4.1">条件查询</a> 
	- <a href="#4.2">排序</a> 
	- <a href="#4.3">单行处理函数</a> 
	- <a href="#4.4">分组函数 (多行处理函数)</a> 
	- <a href="#4.5">group by 和 having </a>
	- <a href="#4.6">查询结果去重 </a>
	- <a href="#4.7">总结，完整的DQL查询语句样式 </a>

5. <a href="#5">连接查询</a> 
	- <a href="#5.1">笛卡尔积现象（笛卡尔乘积现象）</a>
	- <a href="#5.2">内连接 - 等值连接</a> 
	- <a href="#5.3">内连接 - 非等值连接</a> 
	- <a href="#5.4">内连接 - 自连接</a> 
	- <a href="#5.5">外连接</a> 
	- <a href="#5.6">三张表的连接查询</a> 

6. <a href="#6">子查询</a> 
	- <a href="#6.1">where 子句中使用子查询</a>
	- <a href="#6.2">from 子句中使用子查询</a> 
	- <a href="#6.3">select 子句中使用子查询</a> 

7. <a href="#7">union</a> 

8. <a href="#8">limit</a>

9. <a href="#9">除了表查询之外的语句</a> 
	- <a href="#9.1">创建删除表</a> 
	- <a href="#9.2">insert 插入数据</a> 
	- <a href="#9.3">复制表</a> 
	- <a href="#9.4">将查询结果插入到表</a> 
	- <a href="#9.5">修改数据</a> 
	- <a href="#9.6">删除数据</a> 

10. <a href="#10">约束</a> 
	- <a href="#10.1">非空约束 not null</a> 
	- <a href="#10.2">唯一性约束 unique</a> 
	- <a href="#10.3">主键约束 primary key</a> 
	- <a href="#10.4">外键约束 foreign key</a> 

11. <a href="#11">存储引擎</a> 

12. <a href="#12">事务（Transaction）</a> 
	- <a href="#12.1">事务的隔离性</a> 
	- <a href="#12.2">mysql 默认事务自动提交</a> 

13. <a href="#13">索引</a> 
	- <a href="#13.1">索引的使用</a> 

14. <a href="#14">视图</a> 

15. <a href="#15">DBA命令</a> 

16. <a href="#16">数据库设计的三范式</a> 

99. <a href="#99">练习题</a> 
	- <a href="#99.1">时间差的计算</a> 

## <a id="1">Sql 语句分类</a>

1. DQL（数据查询语言）：

	查询语句，凡是 select 语句都是 DQL

2. DML（数据操作语言）：

	insert delete update，对表当中的数据进行增删改

3. DDL（数据定义语言）：

	create drop alter，对表结构的增删改

4. TCL（事务控制语言）：

	commit 提交事务，rollback 回滚事务（T是 Transaction）

5. DCL（数据控制语言）：

	grant 授权、revoke 撤销权限等

## <a id="2">基础指令</a>
 
```sql
<!-- 登陆 -->

1. 查看数据库
show databases; (非 sql 语句，MySQL 命令)

2. 创建属于自己的数据库
create database [名字]; (非 sql 语句，MySQL 命令)

3. 使用
use [名字]; (非 sql 语句，MySQL 命令)

4. 查看当前使用数据库中的表
show tables;

查看其他数据库中的表
show tables from [表名];

5. 初始化数据库
source [.sql文件];

.sql 文件被称为 `sql脚本`。该文件中编写了大量的 sql 语句。

注意：使用 `source` 命令可以执行 sql 脚本。

sql 脚本中的数据量太大的时候，无法打开，请使用 source 命令完成初始化。

6. 删除数据库
drop database [名字];

7. 查看表结构
desc [表名];

8. 查询表数据
select * from [表名];
```

## <a id="3">常用命令</a>

```sql
1. 查看当前使用的数据库
select database();

2. 查看当前版本
select version();

3. 结束一条语句
\c

4. 退出 mySql
exit

5. 查看创建当前表的 sql 语句
show create table [表名];
```

## sql 基础语句

1. 任何 sql 语句以 ; 号结尾

2. sql 语句*不区分*大小写

## <a id="4">查询</a>

```sql
// 查询
select [字段1], [字段2], ... from [表明];

// 这里的字段可以参与数学运算 
// eg :
select [字段1], [字段2(月薪) * 12], ... from [表明];

// 给查询结果的 key 起别名
// 如果 [别名] 是汉字需要用 ' ' 扩起来
// !!! mysql 可以使用单双引号，但是部分数据库不支持双引号，所以推荐全部使用单引号
// !!! 进行了数学运算的字段也可以用 as 改别名
select [字段] as [别名] from user;

// as 关键可以省略
select [字段] [别名] from user;

// 查询全部字段
select * from [表名];
```

### <a id="4.1">条件查询</a>

1. =		等于
2. <> 或 !=	不等于
3. < <=
4. > >=
5. between ... and ... (相当于 >= and <=)
6. is null
7. and		并且
8. or 		或者
9. in 		包含
10. not 	not 可以取非，主要用在 is 或 in 中
11. like	模糊查询，支持 % 或者下划线匹配
	`%` 代表任意多个字符
	`_` 代表任意一个字符


语法格式:
	select
		字段, 字段...
	from
		表名
	where
		条件;

eg:

```sql
elect ename, sal from emp where sal >= 1500;

// 这里的字符串必须拿 '' 扩起来，表示它是个字符串
select sal from emp where ename = 'SMITH';

// 工资在 1000 和 3000 之前 包括左右 [1000, 3000]
// between and 在使用的时候必须左小右大 
select ename, sal from emp where sal between 1000 and 3000

// between and 可以使用在字符串之间 [A, C)
select ename, sal from emp where ename between 'A' and 'C';

// null 的用法
select * from emp where comm is null;
select * from emp where comm is not null;
select * from emp where comm is null or comm = 0;

// in 的效果和 or 是一样，就是写法不一样
select ename, job from emp where job in('salesman', 'manager');

// 名字中第二个字符是 A 的
// select ename, job from emp where ename like '_A%'
// 名字中包含 _ 的
// select ename, job from emp where ename like '%\_%'
```

### <a id="4.2">排序</a>

语法：
	select
		ename, sal
	from
		emp
	order by 
		sal;

1. asc 升序 (默认生序)
2. desc 降序

```sql
// 按工资降序
select ename, sal from emp order by sal desc;

// 按工资降序排列，当工资相同的时候再按照名字的生序排列
// 多个字段排序，越靠前的条件权重越大
select ename, sal from emp order by sal desc, ename asc;

// 这里的 1 是指 ename (不健壮的语句，不推荐)
select ename, sal from emp order by 1 desc;
```

执行顺序
```
select
	字段 			3
from
	表名 			1
where
	条件 			2
order by
	... 			4
```

### <a id="4.3">单行处理函数</a>

单行处理函数：输入一行，输出一行

```sql
// 计算每个员工的年薪
// ！！！ 注意这里的 comm 如果是 null 算出来的年薪就是 0 (所有的数据库只要 null 参与计算，结果就是 null)
select ename, (sal + comm) * 12 as yearsal from emp;
```

ifnull() 空处理函数

ifnull(可能为null的字段, 给予默认值)

```sql
select ename, (sal + ifnull(comm, 0)) * 12 as yearsal from emp;
```

### <a id="4.4">分组函数 (多行处理函数)</a>

多行处理函数的特点： 输入多行，最终输出一行

1. count 计数 
2. sum 求和 
3. avg 平均值 
4. max 最大值 
5. min 最小值 

> 所有的分组函数都是对 "某一组" 数据进行操作的 
>
> 分组函数不可以直接使用在 where 子句当中，因为 group by 是在 where 执行之后才会执行。而分组函数需要在 group by 之后执行。

```sql
// 找出工资总和
select sum(sal) from emp;

select max(sal) from emp;

select min(sal) from emp;

select avg(sal) from emp;

select count(*) from emp;
select count(ename) from emp;
```

> 分组函数自动忽略 NULL

```sql
// 结果为 4 其实不止 4 条
select count (comm) from emp;
```

count 的一点小知识

1. count(\*)
	不是统计某个字段数据的个数，而是统计总记录条数

2. count(某个字段)
	统计该字段中不为 NULL 的条数

分组函数也能组合起来使用

```sql
select count(*), sum(sal), avg(sal), max(sal) from emp;
```

eg：找出工资大于平均工资的员工

```sql
// 嵌套 select 语句 （子查询）
select ename, sal from emp where sal > (select avg(sal) from emp);
```

### <a id="4.5">group by 和 having </a>

group by：按照某个字段或者某些字段进行分组 

having：having 是对分组之后的数据进行再次过滤

> 分组函数一般都会和 group by 联合使用，这也是为什么它成为分组函数。并且任何一个分组函数（count sum avg max min）都是在 group by 语句执行结束之后才会执行。
>
> 当一条 sql 语句没有 group by 的话，整张表的数据会自成一组。

完整查询语句的顺序： <a href="#4.6">总结，完整的DQL查询语句样式 </a>

eg：找出每个工作岗位的最高薪资

```sql
select max(sal), job from emp group by job;
```

> select ename max(sal), job from emp group by job; 
>
> 以上这条查询语句是错误的。当一条语句有 group by 时，select 后面只能跟分组函数和参与分组的字段


eg：找出每个部门不同工作岗位的最高薪资

```sql
// 找出每个部门的最高薪资
select max(sal) from emp group by deptno;

// 找出每个部门不同工作岗位的最高薪资，并根据部门编号排序
select deptno, job, max(sal) from emp group by deptno, job order by deptno;
```

eg：找出每个部门的最高薪资，要求显示薪资大于 2500 的数据

```sql
// 找出每个部门的最高薪资
select max(sal) from emp group by deptno;

// 这样写效率不高
select max(sal) as maxSal, deptno from emp group by deptno having maxSal > 2900;

// 最佳写法 先 where 过滤一遍
select max(sal), deptno from emp where sal > 2900 group by deptno;
```

eg：找出每个部门的平均薪资，要求显示薪资大于 2000 的数据

```sql
// 找出每个部门的平均薪资
select deptno, avg(sal) from emp group by deptno;

// 找出每个部门的平均薪资，并显示大于 2000 的数据
select deptno, avg(sal) as avgSal from emp group by deptno having avgSal > 2000;
```

> 谨记，where 后面不能用分组函数

### <a id="4.6">查询结果去重</a>

distinct 关键字

> distinct 只能出现在所有字段的最前面

```sql
select distinct job from emp;

// 联合 deptno, job 一起去重
select distinct deptno, job from emp;
```

eg：统计岗位的数量
```sql
select count(distinct job) from emp;
```

### <a id="4.7">总结，完整的DQL查询语句样式</a>

```sql
// [ ] 为可省略的
select		5
	..
from		1
	..
[where]		2
	..
[group by]	3
	..
[having]	4
	..
[order by]	6
	..
[limit]		7
	..;
```

## <a id="5">连接查询</a>

在实际的开发中，大部分情况下都不是从单张表中查询数据，一般都是多张表联合查询取出最终的结果。

### 连接查询的分类 

根据*语法*出现的年代来划分：

1. SQL92 (基本没有了) 
2. SQL99 

根据*表的连接方式*来划分，包活： 

1. 内连接 
	- 等值连接 
	- 非等值连接 
	- 自连接
2. 外连接 
	- 左外连接（左连接） 
	- 右外连接（右链接）
3. 全连接（很少用）

### <a id="5.1">笛卡尔积现象（笛卡尔乘积现象）</a> 

eg：找出每一个员工的部门名称，要求显示员工名和部门名。

```sql
// emp 有 14 条数据，dept 有 4 条数据，如果不加任何条件，查询出来的会是 14 * 4 = 56 条记录。称之为 笛卡尔乘积现象
select ename, dname from emp, dept;

// 正规写法 记住用别名 (不过一般不用这种语法，这是 SQL92 的语法)
select e.ename, e.job, d.dname from emp e, dept d where e.deptno = d.deptno;
```

> 加了查询条件避免了笛卡尔积现象之后，并不会减少查询时系统进行的匹配次数，依旧是 14 * 4 = 56次，也就是说不会使查询效率更高，它只不过将无效的查询结果给过滤了。

### <a id="5.2">内连接 - 等值连接</a> 

> 特点：条件是等量关系（就是 on 关键字之后跟的条件是等量关系）

SQL99语法：

> 引入了 join on 语法，将*连接条件*和最终的*结果筛选条件（where）*分开了，语法更清晰

```sql
// inner 是可省略的，只是增加了可读性。inner 表示内连接
...
	A
[inner] join
	B
on
	连接条件
where
...
```

eg：查询每个员工的部门名称，要求显示员工名和部门名

```sql
// SQL92
select e.ename, e.deptno, d.dname from emp e, dept d where e.deptno = d.deptno order by e.deptno;

// SQL99 
select e.ename, e.deptno, d.dname from emp e join dept d on e.deptno = d.deptno;
```

### <a id="5.3">内连接 - 非等值连接</a> 

> 特点：连接条件中的关系是非等量关系

eg：找出每个员工的工资等级，要求显示员工名、工资、工资等级

```sql
select e.ename, e.sal, s.grade from emp e join salgrade s on e.sal between s.losal and s.hisal;
```

### <a id="5.4">内连接 - 自连接</a> 

> 特点：一张表看作两张表。自己连接自己

eg：找出每个员工的上级领导，要求显示员工名和对应的领导名

```sql
select e.empno, e.ename as '员工名字', e.mgr, b.ename as '领导名字' from emp e join emp b on e  gr = b.empno;
```

> 自连接可以是等量关系，也可以是非等量关系

### <a id="5.5">外连接</a> 

内连接和外连接的区别：

内连接：假设 A 和 B 表进行连接，使用内连接的话，凡是 A 表和 B 表能够匹配上的记录查询出来，这就是内连接。AB 两张表**没有主副之分**，两张表是平等的。

外连接：假设 A 和 B 进行连接，使用外连接的话，A B两张表中有**一张表是主表，一张表是副表**，主要查询主表中的数据，捎带的查询副表，当副表中的数据没有和主表中的数据匹配上，副表自动模拟出 NULL 与之匹配。

**外连接的分类**：

1. 左外连接（左连接） 
	左边的表是主表

2. 右外连接（右链接）
	右边的表是主表

> 左连接有右连接的写法，右连接也会有对应的左连接的写法

eg：找出每个员工的上级领导，所有员工必须全部查询出来

```sql
// 内连接
select a.ename '员工', b.ename '领导' from emp a join emp b on a.mgr = b.empno;

// 左外连接 [outer] 表示可以省略
select a.ename '员工', b.ename '领导' from emp a left [outer] join emp b on a.mgr = b.empno;

// 右外连接 [outer] 表示可以省略
select a.ename '员工', b.ename '领导' from emp b right [outer] join emp a on a.mgr = b.empno;
```

> 内外连接最大的区别在于，有主副之分。内连接必须存在数据匹配，不然就会被过滤。外连接当数据不匹配时会补 NULL。


eg：找出那个部门没有员工

```sql
// 找出每个部门对应的员工，并找到员工信息为空的那些数据
select d.* from dept d left join emp e on d.deptno = e.deptno where e.ename is null;
```

### <a id="5.6">三张表的连接查询</a> 

eg：找出每一个员工的部门名称以及工资等级

```sql
select e.ename, d.dname, s.grade from emp e join dept d on e.deptno = d.deptno join salgrade s on e.sal between s.losal and s.hisal;
```

eg：找出每一个员工的部门名称、工资等级、以及上级领导

```sql
select 
	e.ename '员工', d.dname, s.grade, e1.ename '领导' 
from 
	emp e 
join 
	dept d 
on 
	e.deptno = d.deptno 
join 
	salgrade s 
on 
	e.sal between s.losal and s.hisal 
left join 
	emp e1 
on 
	e.mgr = e1.empno;
```

## <a id="6">子查询</a>

定义：select 语句当中嵌套 select 语句，被嵌套的 select 语句是子查询

可出现的位置：

```sql
select
	..(select).
from
	..(select).
where
	..(select).
```

### <a id="6.1">where 子句中使用子查询</a>

eg：找出高于平均薪资的员工信息

```sql
select * from emp where sal > (select avg(sal) from emp);
```

### <a id="6.2">from 子句中使用子查询</a>

eg：找出每个部门平均薪水的薪资等级

```sql
// 找出每个部门平均薪水 将这个表作为 t
select deptno, avg(sal) avgSal from emp group by deptno;

select t.deptno, t.avgSal, s.grade from salgrade s right join (select deptno, avg(sal) avgSal from emp group by deptno) t on t.avgSal between s.losal and s.hisal order by t.deptno;
```

eg：找出每个部门的平均薪水等级

```sql
// 找出每个人的薪水等级
select e.*, s.grade from emp e left join salgrade s on e.sal between s.losal and s.hisal;

// 找个每个部门的平均薪水等级 (错误的写法，这里不需要子查询)
select t.deptno, avg(t.grade) '部门平均的薪水等级' from (select e.*, s.grade from emp e left join salgrade s on e.sal between s.losal and s.hisal) t group by t.deptno order by t.deptno;

// 正确写法
select e.deptno, avg(s.grade) from emp e join salgrade s on e.sal between s.losal and s.hisal group by e.deptno order by e.deptno;
```

### <a id="6.3">select 子句中使用子查询</a>

eg：找出每个员工所在的部门名称，要求显示员工名和部门名

```sql
// 正常写法
select e.ename, d.dname from emp e join dept d on e.deptno = d.deptno;


// 嵌套 select 写法
select e.ename, (select dname from dept d where e.deptno = d.deptno) dname from emp e; 
```

## <a id="7">union</a> 

eg：找出工作岗位是 SALESMAN 和 MANAGER 的员工

```sql
// 两种之前的写法
select ename, job from emp where job = 'MANAGER' or job = 'SALESMAN';
select ename, job from emp where job in ('MANAGER', 'SALESMAN');

// union 写法
select ename, job from emp where job = 'MANAGER' 
union 
select ename, job from emp where job = 'SALESMAN';
```

> 使用 union 被合并的多条查询语句，必须列数相同

## <a id="8">limit</a> 

> 分页查询全靠它
>
> limit 是 mysql 特有的，其他数据库中没有，不通用。 （Oracle 中有一个相同的机制，叫做 rownum）

**作用：**取结果集中的部分数据

**语法：** limit startIndex, length

eg：取出工资前5名的员工

```sql
select ename, sal from emp order by sal desc limit 0, 5;

// 如果舍弃第一个数字，默认就是 0 
select ename, sal from emp order by sal desc limit 5;
```

> limit 是 sql 语句中最后执行的一个环节

eg：找出工资排名在第 4 到第 9 名的员工

```sql
select ename, sal from emp order by sal desc limit 3, 6;
```

## <a id="9">除了表查询之外的语句</a> 

### <a id="9.1">创建删除表</a> 

格式：

```sql
create table 表名(
	字段名1 数据类型,
	字段名2 数据类型,
	字段名3 数据类型,
	...
);
```

MySQL 当中常见的数据类型

 - int 		整数型 
 - bigint	长整型 
 - float	浮点型 
 - char		定长字符串 
 - varchar	可变长字符串 
 - date 	日期类型 
 - BLOB 	二进制大对象（存储图片、视频等流媒体信息） Binary Large Object 
 - CLOB		字符大对象（存储较大文本，比如，可以存储 4G 的字符串）Character Large Object 

> char 和 varchar，字符串长度固定，用 char，不然就是 varchar

> 表名一般用 t_ tbl_ 开头

eg：创建学生表

```sql
create table t_student (
	sno bigint,
	name varchar(255),
	sex char(1),
	classno varchar(255),
	birth char(10)
);
```

***添加默认值：***

```sql
create table t_student (
	sno bigint,
	name varchar(255),
	sex char(1) default '1',
	classno varchar(255),
	birth char(10)
);
```

> 当一条 insert 语句执行成功之后，表格当中必然会多一条记录。即使多的这一行记录当中某些字段是 NULL，也无法再次使用 insert 语句针对这条信息补全信息，只能使用 update 语句。

删表：

```sql
drop table if exists t_student;
```

点击前往：<a href="#10">约束</a> 

### <a id="9.2">insert 插入数据</a> 

语法：

```sql
// 字段个数必须和值的个数一样
insert into 表名 (字段1, 字段2, 字段3, ...) values (值1, 值2, 值3, ...);
```

eg：

```sql
insert into t_student (sno, name, sex, classno, birth) values (1, 'dingzhiyuan', '1', 'class3-1', '1980-10-10');
```

***省略字段名字：*** 

```sql
// 后面的 values 就对数量和类型都有要求，必须匹配
insert into t_student values (9, 'dingzhiyuan', '1', 'class3-1', '1980-10-10');
```

***一次插入多行数据：*** 

```sql
insert into t_student (sno, name, sex, classno, birth) values (2, 'test2', '1', 'class2-1', '1988-10-10'), (3, 'test3', '1', 'class33-1', '1988-10-10'), (4, 'test4', '1', 'class2-1', '1988-10-10');
```

### <a id="9.3">复制表</a> 

复制语法：

```sql
create table 表名 as 查询语句;
```

eg：

```sql
create table emp1 as select * from emp;
```

### <a id="9.4">将查询结果插入到表</a> 

语法：

```sql
insert into 新表名 查询语句;
```

eg：

```sql
// 创建
create table dept1 as select * from dept;

// 插入
insert into dept1 select * from dept;
```

### <a id="9.5">修改数据</a> 

语法格式：

```sql
update 表名 set 字段1 = 值1, 字段2 = 值2, ... where 条件;
```

> 注意：没有条件整张表数据全部更新

```sql
// 更新特定记录
update dept1 set loc = 'shanghai', dname = 'hr' where deptno = 10;

// 更新所有记录
update dept1 set loc = 'x', dname = 'y';
```

> 注意：没办法回滚！！！！
 
### <a id="9.6">删除数据</a> 

语法格式：

```sql
delete from 表名 where 条件;
```

> 注意：没有条件全部删除！！！！

eg：

```sql
delete from dept1 where deptno = 10;
```

***删除大表中的数据：***

> 正常的 delete 语句做的删除属于软删除，它并不会初始化内存，所以它是可以还原的。当数据量非常大时，它会很慢。

语法：

```sql
truncate table 表名;
```

> 增删改查又一个术语：CRUD 
>
> Create（增） Retrieve（检索） Update（修改） Delete（删除）


## <a id="10">约束（Constraint）</a> 

在创建表的时候，可以给表的字段添加相应的约束，添加约束的目的是为了保证表中数据的合法性、有效性、完整性

常见约束：

- 非空约束（not null） 
- 唯一约束（unique） 
- 主键约束（primary key） 
	简称 PK
- 外键约束（foreign key） 
	简称 FK
- 检查约束（check） 
	注意： Oracle 数据库有 check 约束，但是 mysql 没有，目前 mysql 不支持

### <a id="10.1">非空约束 not null</a> 

```sql
drop table if exists t_user;
create table t_user(
	id int,
	username varchar(255) not null,
	password varchar(255)
);
insert into t_user(id, password) values(1, '123');

// ERROR 1364 (HY000): Field 'username' doesn't have a default value
```

> 非空 not null 只有列级约束

### <a id="10.2">唯一性约束 unique</a> 

唯一约束修饰的字段具有唯一性，不能重复。**但可以为 NULL**。

```sql
drop table if exists t_user;
create table t_user(
	id int,
	username varchar(255) unique
);
insert into t_user values(1, 'zhangsan');
insert into t_user values(2, 'zhangsan');

//ERROR 1062 (23000): Duplicate entry 'zhangsan' for key 't_user.username'
```

多个列**联合**起来具有唯一性（表级别约束）：

```sql
drop table if exists t_user;
create table t_user(
	id int,
	usercode varchar(255),
	username varchar(255),
	unique(usercode, username)
);
```

多个列**各自单独**具有唯一性（列级约束）：

```sql
drop table if exists t_user;
create table t_user(
	id int,
	usercode varchar(255) unique,
	username varchar(255) unique
);
```

### <a id="10.3">主键约束 primary key</a> 

**特点：**不能为 NULL，也不能重复 

```sql
drop table if exists t_user;
create table t_user(
	id int primary key,
	username varchar(255),
	email varchar(255)
);
insert into t_user(id, username, email) values(1, 'aaa', '123@163.com'), (2, 'bbb', '222@163.com'), (1, 'ccc', '1345@163.com');

// ERROR 1062 (23000): Duplicate entry '1' for key 't_user.PRIMARY'
```

相关术语： 
	- 主键约束 
		约束本身 `id int primary key` 
	- 主键字段 
		字段 `id` 
	- 主键值 
		插入的值 `1`, `2` 等

主键的**作用**： 
	唯一标示，类似身份证的意思。

主键的**分类**：

根据主键字段的字段数量来划分： 

- 单一主键 

	常用的方式 

- 复合主键（多个字段联合起来添加一个主键约束） 

	不建议使用

根据主键的性质来划分： 

- 自然主键 

	和业务没有关系的自然数字 

- 业务主键 

	主键值和系统的业务挂钩，比如身份证号、银行卡号。不推荐这样。因为以后的业务一旦发生改变的时候，主键值可能也需要随着发生变化 

#### 表级约束的方式定义主键

```sql
drop table if exists t_user;
create table t_user(
	id int,
	username varchar(255),
	primary key(id)
);
```

> 可以定义复合主键，primary key(id, username)。 但是并不推荐

#### mysql 提供主键值自增

```sql
drop table if exists t_user;
create table t_user(
	id int primary key auto_increment,
	username varchar(255)
);

insert into t_user(username) values('a');
insert into t_user(username) values('b');
insert into t_user(username) values('c');
insert into t_user(username) values('d');
select * from t_user;
```

> Oracle 当中也提供了一个自增机制，叫做： 序列（sequence）

### <a id="10.4">外键约束 foreign key</a> 

业务背景：
	
请设计数据库表，用来维护学生和班级的信息。

1. 一张表存储所有数据 
	
	不推荐，数据冗余

2. 两张表（班级表和学生表）

```sql
// 先删子再删父，先创父再创子
drop table if exists t_student;
drop table if exists t_class;
create table t_class(
cno int primary key,
cname varchar(255)
);

create table t_student(
sno int primary key, 
sname varchar(255), 
classno int,
foreign key(classno) references t_class(cno)
);

insert into t_class(cno, cname) values(101, 'xxxx'), (102, 'yyyy');
insert into t_student(sno, sname, classno) values(1, 'a', 101), (2, 'b', 102), (3, 'c', 101), (4, 'd', 101), (5, 'e', 102);
select * from t_class;
select * from t_student;
```

这里添加外键约束表示它的值必须来自 t_class 的 cno，如果插入的值 t_class 中不存在，则报错。

表示 t_student 中的 classno 字段引用 t_class 表中的 cno 字段，此时 t_student 表叫做**子表**。t_class 表叫做**父表**。若进行删除表的操作，必须先删除子表，再删除父表。若进行创建，先父后子。 

> 注意： 
> 
> 1. 外键可以为 NULL 
> 
> 2. 外键引用的键，不一定是主键，但是至少需要有唯一性 

## <a id="11">存储引擎</a> 

存储引擎决定了表在创建之后，数据的存储方式

完整的建表语句，多了指定引擎、字符集等。若不指定引擎，将使用默认的引擎 InnoDB，默认的字符集 UTF8：

```sql
CREATE TABLE `t_student` (
  `sno` int NOT NULL,
  `sname` varchar(255) DEFAULT NULL,
  `classno` int DEFAULT NULL,
  PRIMARY KEY (`sno`),
  KEY `classno` (`classno`),
  CONSTRAINT `t_student_ibfk_1` FOREIGN KEY (`classno`) REFERENCES `t_class` (`cno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

> 注意： 
> 
> 1. 在 MySQL 当中，凡是标识符是可以使用飘号扩起来的。不过最好别用，不兼容别的数据库 
> 
> 2. 存储引擎这个名字只有在 mysql 中存在。（Oracle 中有对应的机制，但是不叫做存储引擎。Oracle 中没有特殊的名字，就是“表的存储方式”）

查看可用引擎的种类：

```sql
show engines;
```

常见的存储引擎：
  
|Engine|Support|Comment|Transactions（是否事务）|XA|Savepoints|
| ---- | ---- | ---- | ---- | ---- | ---- |
|MyISAM|YES|MyISAM storage engine|NO|NO|NO|
|InnoDB|DEFAULT|Supports transactions, row-level locking, and foreign keys|YES|YES|YES|
|MEMORY|YES|Hash based, stored in memory, useful for temporary tables|NO|NO|NO|

各引擎的特点： 

1. MyISAM

	- 最常用的，但不是默认的 
	- 结构：每个表包含三个文件 格式文件.frm、数据文件.MYD、检索文件.MYI 
	- 有点：可被压缩，节省存储空间。并且可以转换为只读表，提交检索效率 

2. InnoDB

	- 默认的 
	- 结构：表的结构存储在 .frm 文件中。数据存储在 tablespace 这样的表空间中（逻辑概念），无法被压缩，无法转换成只读表 
	- 重磅：在 MySQL 服务器崩溃后提供自动恢复的功能 
	- 支持级联删除，级联更新 
	- 优点：支持事务、行级锁、外键锁。这种存储引擎数据的**安全**得到保障 
 
3. MEMORY

	- 之前叫做 HEAP 引擎 
	- 缺点：不支持事务。数据容易丢失。因为所有数据和索引都是存储在内存当中的 
	- 优点：快 

## <a id="12">事务（Transaction）</a> 

**理解：**一个事务是一个完整的业务逻辑单元，不可再分 

比如：银行账户转账，从 A 账户向 B 账户转账 10000。需要执行两条 update 语句

```sql
update t_act set balance = balance - 10000 where actno = 'act-001';
update t_act set balance = balance + 10000 where actno = 'act-002';
```

以上两条 DML 语句必须同时成功，或者同时失败，不允许出现一条成功，一条失败。

要想保证以上的两条 DML 语句同时成功或者失败，那么就需要使用数据的“事务机制”。

事务的存在是为了保护数据的安全。

> 只有 DML（数据操作语言 insert delete update）语句才支持事务，因为只有这类语句才和数据相关
> 
> 基本上所有的业务，都需要多条 DML 语句来操作，所以事务才如此重要

### 事务的特点

1. A 原子性 

	事务是最小的工作单元，不可再分

2. C 一致性

	事务必须保证多条 DML 语句同时成功或者同时失败

3. I 隔离性

	事务 A 和事务 B 之间具有隔离性

4. D 持久性

	最终数据必须持久化到硬盘文件中，事务才算成功结束

### <a id="12.1">事务的隔离性</a> 

事务隔离性存在隔离级别，理论隔离级别包括4个：

1. 第一级别：未读提交（read uncommitted）

	对方事务还没有提交，我们当前事务可以读取到对方未提交的数据。

	读未提交存在脏读（Dirty Read）现象：表示读到了脏的数据。

2. 第二级别：读已提交（read committed）

	对方事务提交之后的数据我方可以读取到。

	它解决了：脏读现象没有了。

	读已提交存在的问题是：不可重复读。

	// 这里不管我事务是否完成，都可以读到对方提交的最新信息，而不是开启事务那时的数据

3. 第三级别：可重复读（repeatable read）

	它解决了：不可重复读问题。

	// 它读的永远是我开启事务时，读到的数据，读不到对方提交的最新数据

4. 第四级别：序列化读/串行化读（serializable）

	它解决了所有问题。

	效率低。需要事务排队。

> Oracle 默认的隔离级别是：读已提交 
> 
> MySQL 默认的隔离级别是：可重复读

### <a id="12.2">mysql 默认事务自动提交</a> 

> mysql 事务默认情况下是自动提交的。（什么是自动提交？只要执行任意一条 DML 语句则提交一次。）

如果不关闭事务的自动提交，每次修改完数据，执行 `rollback` 都是没效果的。

关闭事务的自动提交：`start transaction`

```sql
start transaction;
.
.
. [插入，修改 等操作]
.
.
[rollback] // 此时如果 rollback 会回到输入 start transaction 之前的状态
commit; 
[rollback] // 此时如果 rollback 没有效果，依旧是 commit 之后的状态
```

> 事务进行时自增的主键，rollback 虽然可以回滚数据，但是无法回滚自增过的主键。

**更改和读取当前事务级别：** 

```sql
set global transaction isolation level REPEATABLE READ;

select @@global.transaction_isolation;
```

## <a id="13">索引</a> 

索引就相当于一本书的目录，通过目录可以快速找到对应的资源。

> 索引是给某一个字段添加，或者说某些字段添加。

在数据库方面，查询一张表的时候有两种检索方式：

1. 全表扫描 

2. 根据索引检查（效率很高） 

	最根本的原理是缩小了扫描的范围。

索引虽然可以提高检索效率，但是不能随意的添加索引，因此索引也是数据库当中的对象，也需要数据库不断的维护。是有维护成本的。比如，表中的数据经常被修改这样就不适合添加索引，因为数据一旦修改，索引需要重新排序，进行维护。

实现原理：

通过 B Tree 缩小扫描范围，底层索引进行了排序、分区，索引会携带数据在表中的“物理地址”，最终通过索引检索到数据之后，获取到关联的物理地址，通过物理地址定位表中的数据，效率是最高的。

### <a id="13.1">索引的使用</a> 

什么时候考虑给字段添加索引：

1. 数据量庞大 
	
	根据实际需求来确定 

2. 该字段很少的 DML 操作（不是经常修改） 

	因为字段进行修改操作，索引也需要维护 

3. 该字段经常出现在 where 子句种 

> 主键和具有 unique 约束的字段自动会添加索引 
> 
> 所以通常根据主键查询的效率会很高 

查看 sql 语句的执行计划：

```sql
explain select语句
```

添加索引：

```sql
create index 索引名称 on 表名(字段名);
```

删除索引：

```sql
drop index 索引名称 on 表名;
```

### 索引的分类

1. 单一索引 

	给单个字段添加的索引 

2. 复合索引 
	
	给多个字段联合起来添加的1个索引

3. 主键索引 

	主键上会自动添加索引

4. 唯一索引 

	有 unique 约束的字段上会自动添加索引 

### 索引什么时候失效

> 模糊查询的时候，第一个通配符使用的是 `%`，这个时候索引是失效的。

## <a id="14">视图</a> 

视图：站在不同的角度去看数据。（同一张表的数据，通过不同的角度去看待）

创建视图：

create view 视图名 as DQL语句（select 语句）

```sql
create view myview as select empno, ename from emp;

// 可以直接查询视图
select * from myview;

// 对视图进行更改，删除数据，会直接印象到原表
update ...
delete ...

drop view myview;
```

> 对视图进行增删改查，会影响到原表数据。（通过视图影响原表数据的，不是直接操作原表）

视图的**作用**：视图可以隐藏表的实现细节。保密级别较高的系统，数据库只对外提供相关的视图，java 程序员只对视图进行 CRUD；

## <a id="15">DBA命令</a> 

导入：

```
create database dzyTest;
use dzyTest;
source D:\dzyTest.sql;
```

导出：

> 这个是在命令行窗口中执行，不用登陆 mysql

```
// 导出整个库则不用加表名，导出指定表则加上表名
mysqldump 数据库名 [指定表]>导出文件的绝对地址.sql -uroot -p333

mysqldump dzyTest>D:\dzyTest.sql -uroot -p333
```

## <a id="16">数据库设计的三范式</a> 

1. 任何一张表都应该有主键，并且每一个字段原子性不可再分

2. 建立在第一范式的基础之上，所有非主键字段完全依赖主键，不能产生部分依赖

	部分依赖指的是，比如这里有教师，教师不能依赖学生的 id，应该有自己的 id

	比如：多对多，学生和教师的关系。**三张表，关系表两个外键**

```
t_student: sno(pk) sname

t_teacher: tno(pk) tname

t_student_teacher_relation: id(pk) sno(fk) tno(fk)
```

3. 建立在第二范式的基础之上，所有非主键字段直接依赖主键，不能产生传递依赖

	比如：一对多，学生和班级的关系。**两张表，多的表加外键**

```
t_class: cno(pk) cname

t_student: sno(pk) sname classno(fk)
```

> 提醒：在实际的开发中，以满足客户的需求为主，有的时候会拿冗余换执行速度。

**一对一**怎么设计？比如两张表，都存用户信息，一张是常用的，比如用户名、密码。另一张是不常用的信息。

1. 主键共享

```
t_user_login: id(pk) username password ...

t_user_detail: id(pk + fk) realname tel ...
```

2. 外键唯一

```
t_user_login: id(pk) username password ...

t_user_detail: id(pk) realname tel userid(fk + unique) ...
```

## <a id="99">练习题</a> 

1. 取得每个部门最高薪水的人员名称

```sql
select 
	e.deptno, e.ename, e.sal 
from 
	emp e 
join 
	(select deptno, max(sal) msal from emp group by deptno) t 
where 
	e.sal = t.msal and e.deptno = t.deptno
order by
	e.deptno;
```

2. 那些人的薪水在部门平均薪水之上

```sql
select 
	e.deptno, e.ename, e.sal, t.asal
from
	emp e
join
	(select deptno, avg(sal) asal from emp group by deptno) t
where
	e.sal >= t.asal and e.deptno = t.deptno
order by
	e.deptno;
```

3. 取得部门中（所有人的）平均的薪水等级

```sql
select 
	e.deptno, avg(s.grade)
from 
	emp e 
join 
	SALGRADE s on e.sal between s.losal and s.hisal
group by
	e.deptno
order by
	e.deptno;
```

4. 不准用组函数（Max），取得最高薪水（给出两种解决方案）

```sql
select sal from emp order by sal desc limit 1;
```

```sql
select 
	sal 
from 
	emp 
where 
	sal 
not in 
	(select distinct e.sal from emp e join emp t on e.sal < t.sal);
```

5. 取得平均薪水最高的部门的部门编号

```sql
select deptno, avg(sal) asal from emp group by deptno order by asal desc limit 1;
```

```sql
select 
	deptno, avg(sal) avgsal 
from 
	emp 
group by 
	deptno 
having 
	avgsal = (select max(t.asal) from (select deptno, avg(sal) asal from emp group by deptno) t);
```

```sql
select max(t.avgsal) from (select avg(sal) avgsal from emp group by deptno) t;
```

> having 分组之后的再过滤

6. 取得平均薪水最高的部门的部门名称

```sql
select 
	e.deptno, t.dname, avg(e.sal) avgsal 
from 
	emp e
join
	dept t
on
	e.deptno = t.deptno
group by 
	e.deptno 
order by 
	avgsal desc 
limit 1;
```

7. 求平均薪水的等级最高的部门的部门名称

```sql
select 
	s.grade, t.deptno, d.dname 
from 
	salgrade s 
join 
	(select e.deptno, avg(e.sal) avgSal from emp e group by e.deptno) t 
on 
	t.avgSal between s.losal and s.hisal
join
	dept d
on
	t.deptno = d.deptno
where
	s.grade = (select grade from salgrade where (select avg(sal) avgSal from emp group by deptno order by avgSal desc limit 1) between losal and hisal);
```

8. 取得比普通员工（员工代码没有在 mgr 字段上出现的）的最高薪水还要高的领导人姓名

```sql
// 领导目录
select distinct mgr from emp where mgr is not null;

// 获取普通员工的最高薪资
select max(sal) from emp where empno not in (select distinct mgr from emp where mgr is not null);

// 最终
select 
	ename, sal 
from 
	emp 
where 
	sal 
> 
	(select max(sal) from emp where empno not in (select distinct mgr from emp where mgr is not null));
```

> not in 在使用的时候，后面小括号中记得排出 NULL

9. 取得每个薪水等级有多少员工

```sql
select 
	s.grade, count(*)
from 
	emp e 
join 
	salgrade s 
on 
	e.sal between s.losal and s.hisal 
group by 
	s.grade
order by
	s.grade;
```

// 13 很难的面试题
```sql
select cno from c where cteather = '黎明';

select (distinct sno), s.sname from sc where cno not in (select cno from c where cteather = '黎明') join s on s.sno = sno;
```

10. 列出受雇日期早于其直接上级的所有员工的编号、姓名、部门名称

```sql
select 
	e1.ename '员工', e1.empno, e1.hiredate, d.dname '部分名称', e2.ename '领导', e2.hiredate 
from 
	emp e1 
join 
	emp e2 
on 
	e1.mgr = e2.empno 
join 
	dept d 
on 
	e1.deptno = d.deptno
where
	e1.hiredate < e2.hiredate;
```

11. 列出部门名称和这些部门的员工信息，同时列出那些没有员工的部门

```sql
select d.dname, e.* from emp e right join dept d on e.deptno = d.deptno;
```


12. 列出至少有 5 个员工的所有部门

```sql
select 
	d.dname, t.count 
from 
	dept d 
join 
	(select deptno, count(*) count from emp group by deptno having count >= 5) t 
on 
	d.deptno = t.deptno;
```

13. 列出薪资比 "SMITH" 多的所有员工信息

```sql
select * from emp where sal > (select sal from emp where ename = 'SMITH');
```

14. 列出最低薪资大于 1500 的各种工作及从事此工作的全部雇员人数

```sql
select job, min(sal) minSal, count(*) jobCount from emp group by job having minSal > 1500;
```

15. 列出薪金高于公司平均薪金的所有员工，及其所在部门、上级领导、雇员的工资等级

```sql
select 
	e1.ename '员工姓名', d.dname '部门', e2.ename '领导姓名', e1.sal, s.grade
from 
	emp e1
join 
	dept d
on 
	e1.deptno = d.deptno
left join
	emp e2
on
	e1.mgr = e2.empno
join
	salgrade s
on
	e1.sal between s.losal and s.hisal
where 
	e1.sal > (select avg(sal) from emp);
```

### <a id="99.1"></a> 
16. 列出在每个部门工作的员工数量，平均工资和平均服务期限

```sql
select
	d.deptno, count(e.ename), ifnull(avg(e.sal), 0), ifnull(avg(timestampdiff(YEAR, e.hiredate, now())), 0) avgServiceYear
from
	emp e
right join
	dept d
on
	e.deptno = d.deptno
group by
	d.deptno;
```




















