```
SELECT column1, column2
FROM table1, table2
WHERE [ conditions ]  		//条件
GROUP BY column1, column2	//分组
HAVING [ conditions ] 		//过滤重复
ORDER BY column1, column2	//排序
```
# 关键字

1. Like  
 LIKE 运算符是用来匹配通配符指定模式的文本值。  
 百分号 % 代表零个、一个或多个数字或字符。下划线 _ 代表一个单一的数字或字符。  

2. Glob  
 GLOB 运算符是用来匹配通配符指定模式的文本值。
 与 LIKE 运算符不同的是，GLOB 是 **大小写敏感的**
 星号 * 代表零个、一个或多个数字或字符。问号 ? 代表一个单一的数字或字符。  

3. Limit  
 LIMIT 子句用于限制由 SELECT 语句返回的数据数量。  

4. Order By  
 ORDER BY 子句是用来基于一个或多个列按升序或降序顺序排列数据。
 升： ASC  降：DESC  

5. Group By  
 GROUP BY 子句用于与 SELECT 语句一起使用，来对相同的数据进行分组。  
 *在 SELECT 语句中，GROUP BY 子句放在 WHERE 子句之后，放在 ORDER BY 子句之前。*  

 eg: 按 NAME 分组，并将相同 NAME 的 SALARY 相加，结果根据 NAME 排序。
 ```
 SELECT NAME, SUM(SALARY) FROM COMPANY GROUP BY NAME ORDER BY NAME;
 ```

6. Having  
 HAVING 子句允许指定条件来过滤将出现在最终结果中的分组结果。  
 *HAVING 子句则在由 GROUP BY 子句创建的分组上设置条件。*
 *在一个查询中，HAVING 子句必须放在 GROUP BY 子句之后，必须放在 ORDER BY 子句之前。*
 
 eg: 显示名称计数大于 2 的所有记录
 ```
 SELECT * FROM COMPANY GROUP BY name HAVING count(name) > 2;
 ```

7. Distinct  
 DISTINCT 关键字与 SELECT 语句一起使用，来消除所有重复的记录，并只获取唯一一次记录。  
 
 eg: 
 ```
 SELECT DISTINCT name FROM COMPANY;
 ```

8. Join  
 三种链接方式  
 - 交叉连接 : CROSS JOIN  
   把第一个表的每一行与第二个表的每一行进行匹配。如果两个输入表分别有 x 和 y 行，则结果表有 x * y 行。
 - 内连接	 : INNER JOIN
   根据连接谓词结合两个表（table1 和 table2）的列值来创建一个新的结果表。
 - 外连接 : OUTER JOIN  
   最初的结果表与内链接计算方式相同。一旦主连接计算完成，将所有操作表中任何未连接的行合并进来，外连接的列使用 NULL 值，将它们附加到结果表中。  

9. Unions  
 UNION 子句/运算符用于合并两个或多个 SELECT 语句的结果，不返回任何重复的行。  
 *为了使用 UNION，每个 SELECT 被选择的列数必须是相同的，相同数目的列表达式，相同的数据类型，并确保它们有相同的顺序，但它们不必具有相同的长度。*


# 常用函数
*大小写不敏感*

1. count  
 用来计算一个数据库表中的行数  
 ```
 SELECT count(*) FROM COMPANY;
 ```

2. max、min  
 允许我们选择某列的最大值、最小值  
 ```
 SELECT max(salary) FROM COMPANY;
 ```


3. 算术类
 avg : 计算某列的平均值  
 abs : 数值参数的绝对值  
 sum : 为一个数值列计算总和  
 random : 随机数  
 ```
 SELECT avg(salary) FROM COMPANY;
 SELECT random() AS Random;
 ```

4. 函数类  
 upper : 字符串转换为大写字母
 lower : 字符串转换为小写字母
 length : 返回字符串的长度  
 ```
 SELECT upper(name) FROM COMPANY;
 SELECT name, length(name) FROM COMPANY;
 ```

5. sqlite_version  
 返回 SQLite 库的版本
 ```
 SELECT sqlite_version() AS 'SQLite Version';
 ```











