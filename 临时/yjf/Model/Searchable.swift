//
//  Searchable.swift
//  YJF
//
//  Created by edz on 2019/6/15.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol Searchable: class {
    /// 地区
    var district: String? {get set}
    /// 居室
    var roomNum: [String]? {get set}
    /// 面积
    var area: (Int, Int)? {get set}
    /// 面积显示的字符串
    var areaStr: String? {get set}
    /// 价格
    var price: (Int, Int)? {get set}
    /// 价格显示的字符串
    var priceStr: String? {get set}
    
    var header: HomeSectionHeader {get}
    
    var popView: HomePopView {get}
    /// 检查状态
    func checkSectionHeader(_ except: Int)
    /// 点击背景的操作
    func popBgClickDismiss()
    /// 更新数据的 api
    func apiFunc()
    /// 选择地区
    func selectDistrict(_ district: String?)
    /// 选择居室
    func selectRoomNum(_ roomNums: [String]?)
    /// 选择面积和价格
    func selectAreaAndPrice(_ value: (Int, Int)?, str: String?, type: String)
    
    func reset()
    
    func homeAndSearchReset()
}

extension Searchable {
    
    func reset() {
        popView.dismiss()
        district = nil
        header.setTilte(0, title: nil)
        roomNum = nil
        header.setTilte(1, title: nil)
        area = nil
        areaStr = nil
        header.setTilte(2, title: nil)
        price = nil
        priceStr = nil
        header.setTilte(3, title: nil)
        apiFunc()
        homeAndSearchReset()
    }
    
    func checkSectionHeader(_ except: Int = 99) {
        func getTilte(_ index: Int) -> String? {
            switch index {
            case 0:
                return district
            case 1:
                return roomNum?.joined(separator: "-")
            case 2:
                return areaStr
            default:
                return priceStr
            }
        }
        (0..<4).forEach { (index) in
            if except != index {
                header.setTilte(index, title: getTilte(index))
            }
        }
    }
    
    func popBgClickDismiss() {
        header.showType = nil
        checkSectionHeader()
    }
    
    func selectDistrict(_ district: String?) {
        popView.dismiss()
        let old = self.district
        self.district = district
        header.setTilte(0, title: district)
        if old != district {
            apiFunc()
        }
    }
    
    func selectRoomNum(_ roomNums: [String]?) {
        popView.dismiss()
        let old = self.roomNum
        self.roomNum = roomNums
        header.setTilte(1, title: roomNums?.joined(separator: "-"))
        if old != roomNum {
            apiFunc()
        }
    }

    func selectAreaAndPrice(_ value: (Int, Int)?, str: String?, type: String) {
        guard let type = FilterType(rawValue: type) else {return}
        popView.dismiss()
        if type == .area { // 面积
            let old = area
            area = value
            areaStr = str
            header.setTilte(2, title: str)
            if !(old?.0 == value?.0 && old?.1 == value?.1) {
                apiFunc()
            }
        }else {// 价格
            let old = price
            price = value
            priceStr = str
            header.setTilte(3, title: str)
            if !(old?.0 == value?.0 && old?.1 == value?.1) {
                apiFunc()
            }
        }
    }
}
