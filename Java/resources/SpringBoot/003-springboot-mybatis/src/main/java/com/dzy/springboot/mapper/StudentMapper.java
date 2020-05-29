package com.dzy.springboot.mapper;

import com.dzy.springboot.model.Student;

public interface StudentMapper {
    int deleteByPrimaryKey(Integer id);

    // 插入
    int insert(Student record);

    // 条件插入（null的判断）
    int insertSelective(Student record);

    Student selectByPrimaryKey(Integer id);

    // 条件更新（null的判断）
    int updateByPrimaryKeySelective(Student record);

    // 更新
    int updateByPrimaryKey(Student record);
}