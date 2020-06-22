package com.dzy.springboot.web;

import com.dzy.springboot.model.Student;
import com.dzy.springboot.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

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
