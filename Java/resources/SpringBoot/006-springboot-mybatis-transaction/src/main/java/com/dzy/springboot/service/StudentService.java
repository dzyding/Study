package com.dzy.springboot.service;

import com.dzy.springboot.model.Student;

public interface StudentService {
    Student queryStudentById(int id);

    int update(Student student);
}
