package com.dzy.springboot.web;

import com.dzy.springboot.model.Student;
import com.dzy.springboot.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * 控制层，直接处理 web 传来的请求
 */
@Controller
public class StudentController {

    // 注入业务层
    @Autowired
    private StudentService stuService;

    @RequestMapping(value = "/student")
    public @ResponseBody Object student(Integer id) {
        Student stu = stuService.queryStudentById(id);
        return stu;
    }
}
