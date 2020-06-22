package com.dzy.springboot.service.impl;

import com.dzy.springboot.mapper.StudentMapper;
import com.dzy.springboot.model.Student;
import com.dzy.springboot.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StudentServiceImpl implements StudentService {

    @Autowired
    private StudentMapper studentMapper;

    @Override
    public Student queryStudentById(int id) {
        return studentMapper.selectByPrimaryKey(id);
    }

    @Transactional
    @Override
    public int update(Student student) {
        // 成功
        int i = studentMapper.updateByPrimaryKeySelective(student);
        // 失败
        int a = 10/0;
        return i;
    }
}
