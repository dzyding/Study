## 导航

1. <a href="#1">Mybatis 逆向</a> 
    - <a href="#1.1">添加 mybatis 依赖、mysql 驱动</a>  
    - <a href="#1.2">使用 Mybatis 提供的逆向工程生成尸体 bean，映射文件，DAO 接口</a>  
    - <a href="#1.3">Web 工程的一些基本配置</a>  
    - <a href="#1.4">关于 Mapper 映射文件存放的位置的写法有以下两种</a>  

2. <a href="#2">SpringBoot 中的事务</a>  

3. <a href="#3">SpringBoot 中 SpringMVC 的常用注解</a>  

4. <a href="#4">RESTful</a>  

5. <a href="#5">关闭和自定义启动 LOGO </a>  

6. <a href="#6">拦截器</a>  

7. <a href="#7">设置字符编码</a>  

8. <a href="#8">logback</a>  


## <a id="1">Mybatis 逆向</a> 

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

### <a id="1.1">添加 mybatis 依赖、mysql 驱动</a> 

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

### <a id="1.2">使用 Mybatis 提供的逆向工程生成尸体 bean，映射文件，DAO 接口</a> 

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

### <a id="1.3">Web 工程的一些基本配置</a> 

创建 Controller

```java
@Controller
public class StudentController {

    @Autowired
    private StudentService studentService;

    @RequestMapping(value = "/student")
    public @ResponseBody Student queryStudentById(Integer id) {
        Student student = studentService.queryStudentById(id);
        return student;
    }
}
```

创建 Service

```java
public interface StudentService {

    Student queryStudentById(Integer id);
}

@Service
public class StudentServiceImpl implements StudentService {

    @Autowired
    private StudentMapper studentMapper;

    @Override
    public Student queryStudentById(Integer id) {
        return studentMapper.selectByPrimaryKey(id);
    }
}
```

扫描 Mapper 文件的两种方式

```java
@Mapper
public interface StudentMapper {
    .
    .
    .
}
```

```java
@SpringBootApplication
@MapperScan(basePackages = "com.dzy.springboot.mapper")
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

### <a id="1.4">关于 Mapper 映射文件存放的位置的写法有以下两种</a> 

1. 将 Mapper 接口和 Mapper 映射文件存放到 `src/main/java` 同一目录下，还需要在 `pom` 文件中手动指定资源文件夹路径 `resources`

```xml
<build>
    <!--手动指定文件夹为 resources-->
    <resources>
        <resource>
            <directory>src/main/java</directory>
            <includes>
                <include>**/*.xml</include>
            </includes>
        </resource>
    </resources>
...
</build>
```

2. 将 Mapper 接口和 Mapper 映射文件分开存放

    Mapper 接口类（class 文件）存放到 src/main/java 目录下

    Mapper 映射文件（xml 文件）存放到 resources/mapper（类路径）

在 springboot 核心配置文件（application.properties）中指定 mapper 映射文件存放到的位置

```
mybatis.mapper-locations=classpath:mapper/*.xml
```

## <a id="2">SpringBoot 中的事务</a> 

```java
@Transactional
@Override
public int update(Student student) {
    // 成功
    int i = studentMapper.updateByPrimaryKeySelective(student);
    // 失败
    int a = 10/0;
    return i;
}
```

正常情况下，第一条命令成功，第二条命令失败，会导致“事务没有完成”，但是数据库的值却变了。这里加上 `@Transactional` 注解，就会在第一条命令失败的同时，回滚第一条命令的操作结果。

## <a id="3">SpringBoot 下 Spring MVC 的常用注解</a> 

1. `@Controller`

    最常用的，表示控制层

```java
@Controller
public class StudentController {

    @RequestMapping(value = "/student")
    @ResponseBody
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }
}
```

2. `@RestController`
    
    相当于控制层类上加 `@Controller` + 所有的方法上加 `@ResponseBody`

    意味着当前控制层类中所有方法返还的都是 JSON 对象

```java
@RestController
public class StudentController {

    @RequestMapping(value = "/student")
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }
}
```

3. `@RequestMapping`

    最常见的，默认支持 `get`, `post` 请求

```java
@RestController
public class StudentController {

    // 后面的 method 部分可以省略
    @RequestMapping(value = "/student", method = {RequestMethod.GET, RequestMethod.POST})
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }
}
```

4. `@GetMapping`

    通常用来**查询**

```java
@RestController
public class StudentController {

    // 等同
    //@RequestMapping(value = "/student", method = {RequestMethod.GET})
    @GetMapping(value = "/student")
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }
}
```

5. `@PostMapping`

    通常用来**新增**

```java
@RestController
public class StudentController {

    // 等同
    //@RequestMapping(value = "/insert", method = {RequestMethod.POST})
    @PostMapping(value = "/insert")
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }
}
```

6. `@PutMapping`

    通常用来**更新**

```java
@RestController
public class StudentController {

    // 等同
    //@RequestMapping(value = "/update", method = {RequestMethod.PUT})
    @PutMapping(value = "/update")
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }
}
```

7. `@DeleteMapping`

    通常用来**删除**

```java
@RestController
public class StudentController {

    // 等同
    //@RequestMapping(value = "/delete", method = {RequestMethod.DELETE})
    @DeleteMapping(value = "/delete")
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }
}
```

## <a id="4">RESTful</a> 

它是一种互联网软件架构设计**风格**，但它并不是标准。

> Demo 可见 007-springboot-springmvc

eg：

```
// 正常的
http://localhost:8080/boot/order?id=1021&status=1

// RESTful
http://localhost:8080/boot/order/1021/1
```

```java
// 常见版本
@RequestMapping(value = "/student"})
public Object student() {
    Student student = new Student();
    student.setId(1001);
    student.setName("zhangsan");
    return student;
}

// RESTful
@RequestMapping(value = "student/detail/{id}/{age}")
public Object student(
    @PathVariable("id") Integer id, 
    @PathVariable("age") Integer age
) {
    Map<String, Object> retMap = new HashMap<>();
    retMap.put("id", id);
    retMap.put("age", age);
    return retMap;
}

/**
 *  这里如果这样写，会跟上面的冲突，系统无法识别是那个请求
 *
 *  通常的解决方案是：
 *  1. 通过请求方式区分
 *      比如上面的方法 @GetMapping，下面的 student2 方法就用 @DeleteMapping
 */
@RequestMapping(value = "student/detail/{id}/{status}")
public Object student2(@PathVariable("id") Integer id, @PathVariable("status") Integer status) {
    Map<String, Object> retMap = new HashMap<>();
    retMap.put("id", id);
    retMap.put("status", status);
    return retMap;
}
```

## <a id="5">关闭和自定义启动 LOGO </a> 

```java
public static void main(String[] args) {
    // 原始状态
    // SpringApplication.run(Application.class, args);

    // 关闭启动 LOGO
    SpringApplication springApplication = new SpringApplication(Application.class);
    springApplication.setBannerMode(Banner.Mode.OFF);
    springApplication.run(args);

    /**
    自定义LOGO

    在 resource 文件夹中创建 banner.txt 文件，并把 logo（数字符号组成的） 复制进去
    */   
}
```

## <a id="6">拦截器</a> 

> 参考 008-springboot-interceptor

```java
@Configuration // 定义此类为配置文件(即相当于之前的 xml 配置文件)
public class InterceptorConfig implements WebMvcConfigurer {

    /**
     *
     * @param registry InterceptorRegistry 拦截器注册类
     *
     *                 addPathPatterns 添加拦截路径
     *                 excludePathPatterns 排除拦截路径
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        /*
        拦截 user 下的所有访问请求，必须用户登陆后才可访问，
        但是这样拦截的路径中有一些是不需要用户登陆也可以访问的，于是在 exclude 中指明
        */
        String[] addPathPatterns = {
            "/user/**"
        };

        // 要排除的路径，说明不需要用户登陆也可访问
        String[] excludePathPatterns = {
            "/user/out", 
            "/user/error",
            "/user/login", 
            "/user/loginout"
        };
        registry.addInterceptor(new UserInterceptor())
                .addPathPatterns(addPathPatterns)
                .excludePathPatterns(excludePathPatterns);
    }
}
```


```java
// 定义用户拦截器
public class UserInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        System.out.println("进入拦截器");

        // 编写业务拦截的规则
        // 从 session 中获取用户的信息
        User user = (User) request.getSession().getAttribute("user");

        // 判断用户是否登陆
        if (null == user) {
            // 未登录
            response.sendRedirect(request.getContextPath() + "/user/error");
            return  false;
        }

        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }
}
```

> 这里使用了 HttpServletRequest 类，在请求中获取请求参数等。

```java
@RestController
@RequestMapping(value = "/user") // 加在所有请求的前面 比如登陆变成了 /user/login
public class UserController {

    // 用户登陆的请求
    @RequestMapping(value = "/login")
    public Object login(HttpServletRequest request) {
        // 将用户的信息存放到 session 中
        User user = new User();
        user.setId(1001);
        user.setUsername("zhangsan");
        request.getSession().setAttribute("user", user);

        return "login SUCCESS";
    }

    @RequestMapping(value = "/loginout")
    public Object loginout(HttpServletRequest request) {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null)  {
            return "not login";
        }
        request.getSession().removeAttribute("user");
        return "loginout SUCCESS";
    }

    // 该请求需要用户登录之后才可访问
    @RequestMapping(value = "/center")
    public Object center() {
        return "See Center Message";
    }

    // 该请求不登陆也可访问
    @RequestMapping(value = "/out")
    public Object out() {
        return "Out see anytime";
    }

    // 如果用户未登录访问了需要登陆才可访问的请求，之后会跳转至该路径
    // 该请求用户不登陆也能访问
    @RequestMapping(value = "/error")
    public Object error() {
        return "error";
    }
}
```

## <a id="7">设置字符编码</a> 

```
// 旧的
spring.http.encoding.enabled=true
spring.http.encoding.force=true
spring.http.encoding.charset=utf-8

// 新的
server.servlet.encoding.enabled=true
server.servlet.encoding.force=true
server.servlet.encoding.charset=utf-8
```

## <a id="8">logback</a> 

1. 添加依赖

```xml
 <dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>
```

2. 配置 logback-spring.xml

> 注意，这里的配置文件名字是固定的

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- 日志级别从低到高分为TRACE < DEBUG < INFO < WARN < ERROR < FATAL，如果设置为WARN，则低于WARN的信息都不会输出 -->
<!-- scan:当此属性设置为true时，配置文件如果发生改变，将会被重新加载，默认值为true -->
<!-- scanPeriod:设置监测配置文件是否有修改的时间间隔，如果没有给出时间单位，默认单位是毫秒。当scan为true时，此属性生效。默认的时间间隔为1分钟。 -->
<!-- debug:当此属性设置为true时，将打印出logback内部日志信息，实时查看logback运行状态。默认值为false。 -->
<configuration scan="true" scanPeriod="10 seconds">
    <contextName>logback</contextName>
    <!--读取配置中心的属性-->
    <!-- <springProperty scope="context" name="logpath" source="logging.path"/>-->
    <!-- name的值是变量的名称，value的值时变量定义的值。通过定义的值会被插入到logger上下文中。定义变量后，可以使“${}”来使用变量。 -->
    <property name="LOG_PATH" value="/Users/edz/Documents/JavaLogs/" />
    <!--输出到控制台-->
    <!-- %m输出的信息,%p日志级别,%t线程名,%d日期,%c类的全名,%-5level:级别从左显示5个字符宽度,%msg:日志消息,%i索引【从数字0开始递增】 -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
        <encoder>
            <!--%logger{50}:表示logger名字最长50个字符，否则按照句点分割-->
            <Pattern>%date [%-5p] [%thread] %logger{60} [%file : %line] %msg%n</Pattern>
            <!-- 设置字符集 -->
            <charset>UTF-8</charset>
        </encoder>
    </appender>

    <!--输出到文件-->
    <!-- 时间滚动输出 level为全部日志 -->
    <appender name="RUNTIME" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!-- 正在记录的日志文件的路径及文件名，注释掉这个按照每天生成一个日志文件 -->
        <!--<file>${LOG_PATH}/public.log</file>-->
        <!--日志文件输出格式-->
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{50} -- %msg%n</pattern>
            <charset>UTF-8</charset> <!-- 设置字符集 -->
        </encoder>
        <!-- 日志记录器的滚动策略，按日期，按大小记录 -->
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!-- 日志归档 后面可以加.zip-->
            <fileNamePattern>${LOG_PATH}public-%d{yyyy-MM-dd}.log</fileNamePattern>
            <!--日志文件保留天数-->
            <maxHistory>10</maxHistory>
            <!--<timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">-->
            <!--&lt;!&ndash;文件达到 最大时会被压缩和切割 &ndash;&gt;-->
            <!--<maxFileSize>10MB</maxFileSize>-->
            <!--</timeBasedFileNamingAndTriggeringPolicy>-->
            <!-- 日志总保存量为200MB -->
            <!--<totalSizeCap>200MB</totalSizeCap>-->
        </rollingPolicy>
    </appender>

    <!--时间滚动输出 level为 ERROR 日志 -->
    <appender name="ERROR" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{50} -- %msg%n</pattern>
            <charset>UTF-8</charset> <!-- 此处设置字符集 -->
        </encoder>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}error-%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>10</maxHistory>
        </rollingPolicy>
        <!-- 此日志文件只记录ERROR级别的 -->
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>ERROR</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

<!--     设置需要打印日志文件路径，mapper 里面主要就是 sql 语句-->
    <logger name="com.dzy.springboot.mapper" level="DEBUG"/>

    <!--开发环境:打印控制台-->
<!--    <springProfile name="dev">-->
        <!--<logger name="com.phfund" level="debug"/>-->
        <root level="DEBUG">
            <appender-ref ref="CONSOLE" />
            <appender-ref ref="RUNTIME" />
            <appender-ref ref="ERROR" />
        </root>
<!--    </springProfile>-->

    <!--生产环境:输出到文件-->
<!--    <springProfile name="prd">-->
<!--        <root level="INFO">-->
<!--            <appender-ref ref="RUNTIME" />-->
<!--            <appender-ref ref="ERROR" />-->
<!--        </root>-->
<!--    </springProfile>-->

</configuration>
```

3. 在需要使用的地方引入 `@Slf4j` 注解，通过 `log.*` 使用

> 提示，如果 `log` 函数无法使用，需要到对应的 IDE 中添加 `lombok` 插件

```java
@RestController
@Slf4j
public class StudentController {

    @Autowired
    private StudentService studentService;

    @RequestMapping(value = "/student")
    public Object queryStudent(Integer id) {
        return studentService.queryStudentById(id);
    }

    @RequestMapping(value = "/student/count")
    public String studentCount() {
        log.trace("进入student接口");
        log.debug("进入student接口");
        log.info("进入student接口");
        log.warn("进入student接口");
        log.error("进入student接口");
        Integer count = studentService.selectCount();
        return "总学生人数：" + count;
    }
}
```




















