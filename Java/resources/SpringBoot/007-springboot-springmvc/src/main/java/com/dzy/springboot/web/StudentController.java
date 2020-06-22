package com.dzy.springboot.web;

import com.dzy.springboot.model.Student;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
public class StudentController {

    @RequestMapping(value = "/student", method = {RequestMethod.GET, RequestMethod.POST})
    public Object student() {
        Student student = new Student();
        student.setId(1001);
        student.setName("zhangsan");
        return student;
    }

    @RequestMapping(value = "student/detail/{id}/{age}")
    public Object student(@PathVariable("id") Integer id, @PathVariable("age") Integer age) {
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
     * @param id
     * @param status
     * @return
     */
    @RequestMapping(value = "student/detail/{id}/{status}")
    public Object student2(@PathVariable("id") Integer id, @PathVariable("status") Integer status) {
        Map<String, Object> retMap = new HashMap<>();
        retMap.put("id", id);
        retMap.put("status", status);
        return retMap;
    }
}

