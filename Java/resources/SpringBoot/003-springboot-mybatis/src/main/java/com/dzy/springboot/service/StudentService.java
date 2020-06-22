package com.dzy.springboot.service;

import com.dzy.springboot.model.Student;


// 业务接口
public interface StudentService {

    /**
     * 根据学生 ID 查询详情
     * @param id
     * @return
     */
    Student queryStudentById(Integer id);
}
