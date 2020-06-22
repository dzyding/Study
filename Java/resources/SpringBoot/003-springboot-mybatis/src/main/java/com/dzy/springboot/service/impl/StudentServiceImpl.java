package com.dzy.springboot.service.impl;

import com.dzy.springboot.mapper.StudentMapper;
import com.dzy.springboot.model.Student;
import com.dzy.springboot.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

// 业务层
@Service
public class StudentServiceImpl implements StudentService {

    // 注入数据处理层
    @Autowired
    private StudentMapper stuMapper;

    @Override
    public Student queryStudentById(Integer id) {
        return stuMapper.selectByPrimaryKey(id);
    }
}
