//
//  PageEnable.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol PageEnable {
    
    var dataArr: [[String : Any]] {get set}
    //分页数据
    var page:    [String : Any]?  {get set}//分页
    //当前页数
    var currentPage: Int?   {get}
    //总页数
    var totalPage:   Int?   {get}
    //总数
    var totalNum:    Int?   {get}
}

extension PageEnable {
    //当前页数
    var currentPage: Int? {
        return page?.intValue("currentPage")
    }
    //总页数
    var totalPage: Int? {
        return page?.intValue("totalPage")
    }
    //总数
    var totalNum: Int? {
        return page?.intValue("totalNum")
    }
}
