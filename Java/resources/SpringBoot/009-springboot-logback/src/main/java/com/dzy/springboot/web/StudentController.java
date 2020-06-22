package com.dzy.springboot.web;

import com.dzy.springboot.model.Student;
import com.dzy.springboot.service.StudentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

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
