package com.dzy.springboot.mapper;

import com.dzy.springboot.model.Student;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface StudentMapper {
    int deleteByPrimaryKey(Integer id);

    int insert(Student record);

    int insertSelective(Student record);

    Student selectByPrimaryKey(Integer id);

    int updateByPrimaryKeySelective(Student record);

    int updateByPrimaryKey(Student record);

    Integer selectStudentCount();
}