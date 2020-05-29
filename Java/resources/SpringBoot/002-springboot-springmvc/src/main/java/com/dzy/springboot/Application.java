package com.dzy.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// SpringBoot 项目启动入口类

// 开启 springboot 配置
@SpringBootApplication
public class Application {

    // springboot 项目代码必须放到 Application 类所在的同级目录或下级目录

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
