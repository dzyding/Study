package com.dzy.springboot.mapper;

import com.dzy.springboot.model.Student;
import org.apache.ibatis.annotations.Mapper;

@Mapper //扫描 DAO 接口到 Spring 容器
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