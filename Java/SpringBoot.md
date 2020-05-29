## Mybatis 逆向

名词解释：

1. model 

	实体类 

2. mapper/dao 

	数据持有层

3. 实体 bean

```
1、所有属性为private
2、提供默认构造方法
3、提供getter和setter
4、实现serializable接口
```

**查看本地数据库，允许远程连接的 host：** 

```sql
use mysql;
 
select host from user where user='root';

update user set host = '192.168.11.%' where user ='root';
```

### 添加 mybatis 依赖、mysql 驱动

1. 集成 mysql 驱动

```xml
<properties>
    <java.version>1.8</java.version>
    <!-- 
    修改父工程管理依赖的版本号
    <mysql.version>5.1.9</mysql.version> 
	-->
</properties>

<dependencies>
	.
	.
	.
<!--MySql驱动-->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <!-- 
        自己指定 mysql 的版本
        <version>5.1.9</version> 
        -->
    </dependency>
</dependencies>
```

2. 集成 mybatis

```xml
<!--MyBatis 整合 SpringBoot 框架的起步依赖-->
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.2</version>
</dependency>
```

### 使用 Mybatis 提供的逆向工程生成尸体 bean，映射文件，DAO 接口

GeneratorConfig.xml 文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN" "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">

<generatorConfiguration>
    <!--指定连接数据库的 JDBC 驱动包所谓位置，指定到你本机的完整路径-->
    <classPathEntry location="/Users/edz/Documents/Git/Study/Java/mysql-connector-java-8.0.20/mysql-connector-java-8.0.20.jar"/>
    <context id="tables" targetRuntime="MyBatis3">
        <commentGenerator>
            <!-- 是否去除自动生成的注释 -->
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>

        <!-- Mysql数据库连接的信息：驱动类、连接地址、用户名、密码 -->
        <jdbcConnection driverClass="com.mysql.cj.jdbc.Driver"
                        connectionURL="jdbc:mysql://[IP地址]:3306/[数据库名]"
                        userId="[数据库账号]"
                        password="[数据库密码]">
        </jdbcConnection>
        <!-- Oracle数据库
            <jdbcConnection driverClass="oracle.jdbc.OracleDriver"
                connectionURL="jdbc:oracle:thin:@***:***:***"
                userId="***"
                password="***">
            </jdbcConnection>
        -->

        <!-- 默认为false，把JDBC DECIMAL 和NUMERIC类型解析为Integer，为true时
        把JDBC DECIMAL 和NUMERIC类型解析为java.math.BigDecimal -->
<!--        <javaTypeResolver >-->
<!--            <property name="forceBigDecimals" value="false" />-->
<!--        </javaTypeResolver>-->

        <!-- 生成 model 类，targetPackage 指定 model 类的包名，targetProject 指定生成的 model 放在那个工程下面 -->
        <javaModelGenerator targetPackage="com.dzy.springboot.model" targetProject="src/main/java">
            <!-- enableSubPackages:是否让schema作为包的后缀 -->
            <property name="enableSubPackages" value="false" />
            <!-- 从数据库返回的值被清理前后的空格 -->
            <property name="trimStrings" value="true" />
        </javaModelGenerator>

        <!-- 生成 MyBatis 的 Mapper.xml 文件，targetPackage 指定 mapper.xml 文件的包名 -->
        <sqlMapGenerator targetPackage="com.dzy.springboot.mapper"  targetProject="src/main/java">
            <!-- enableSubPackages:是否让schema作为包的后缀 -->
            <property name="enableSubPackages" value="false" />
        </sqlMapGenerator>

        <!-- targetProject：mapper接口生成的的位置 -->
        <javaClientGenerator type="XMLMAPPER" targetPackage="com.dzy.springboot.mapper"  targetProject="src/main/java">
            <!-- enableSubPackages:是否让schema作为包的后缀 -->
            <property name="enableSubPackages" value="false" />
        </javaClientGenerator>

        <table tableName="t_student" domainObjectName="Student"
               enableCountByExample="false"
               enableUpdateByExample="false"
               enableDeleteByExample="false"
               enableSelectByExample="false"
               selectByExampleQueryId="false"/>

        <!-- 有些表的字段需要指定java类型
        <table schema="DB2ADMIN" tableName="ALLTYPES" domainObjectName="Customer" >
          <property name="useActualColumnNames" value="true"/>
          <generatedKey column="ID" sqlStatement="DB2" identity="true" />
          <columnOverride column="DATE_FIELD" property="startDate" />
          <ignoreColumn column="FRED" />
          <columnOverride column="LONG_VARCHAR_FIELD" jdbcType="VARCHAR" />
        </table> -->

    </context>
</generatorConfiguration>
```

代码生成插件：

```xml
<!--mybatis 代码自动生成插件-->
<plugin>
    <groupId>org.mybatis.generator</groupId>
    <artifactId>mybatis-generator-maven-plugin</artifactId>
    <version>1.4.0</version>
    <configuration>
        <!--配置文件的位置-->
        <configurationFile>GeneratorMapper.xml</configurationFile>
        <verbose>true</verbose>
        <overwrite>true</overwrite>
    </configuration>
</plugin>
```


















