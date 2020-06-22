package com.dzy.springboot.service.impl;

import com.dzy.springboot.mapper.StudentMapper;
import com.dzy.springboot.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class StudentServiceImpl implements StudentService {

    @Autowired
    private StudentMapper studentMapper;

    @Override
    public Object queryStudentById(Integer id) {
        return studentMapper.selectByPrimaryKey(id);
    }

    @Override
    public Integer selectCount() {
        return studentMapper.selectStudentCount();
    }
}
