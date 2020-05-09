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

## <a id="9.2">insert 插入数据</a> 

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

## <a id="9.3">复制表</a> 

复制语法：

```sql
create table 表名 as 查询语句;
```

eg：

```sql
create table emp1 as select * from emp;
```

## <a id="9.4">将查询结果插入到表</a> 

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

## <a id="9.5">修改数据</a> 

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
 
## <a id="9.6">删除数据</a> 

语法格式：

```sql
delete from 表名 where 条件;
```

> 注意：没有条件全部删除！！！！

eg：

```sql
delete from dept1 where deptno = 10;
```

***删除大表：***

> 正常的 delete 语句做的删除属于软删除，它并不会初始化内存，所以它是可以还原的。当数据量非常大时，它会很慢。

语法：

```sql
truncate table 表名;
```


















