package com.dzy.springboot.web;

import com.dzy.springboot.model.Student;
import com.dzy.springboot.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class StudentController {

    @Autowired
    private StudentService studentService;

    @RequestMapping(value = "/update")
    public @ResponseBody String updateStudentById(int id, String name) {
        Student student = studentService.queryStudentById(id);
        student.setName(name);
        int count = studentService.update(student);
        return "修改ID为" + id + "的学生姓名，结果：" + count;
    }
}
