//
//  RegionManager.swift
//  YJF
//
//  Created by edz on 2019/6/14.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

struct RegionManager {
    
    private var city: String = "武汉市"
    
    private var cityId: Int = 1
    
    private var datas: [Int : [[String : Any]]] = [:]
    
    private static var `default` = RegionManager()
    
    static func save(_ city: String, cityId: Int) {
        RegionManager.default.city = city
        RegionManager.default.cityId = cityId
    }
    
    static func setDatas(_ datas:[[String : Any]]) {
        DispatchQueue.global().async {
            // 所有的行政区
            var regionArr: [[String : Any]] = []
            datas.forEach { (region) in
                var temp = region
                temp.removeValue(forKey: "region")
                regionArr.append(temp)
                
                // 行政区下所有的片区
                if let tempArr = region["region"] as? [[String : Any]],
                    let regionId = region.intValue("id")
                {
                    var districtArr: [[String : Any]] = []
                    tempArr.forEach({ (district) in
                        var temp = district
                        temp.removeValue(forKey: "community")
                        districtArr.append(temp)
                        
                        // 片区下所有的小区
                        if let communityArr = district["community"] as? [[String : Any]],
                            let districtId = district.intValue("id")
                        {
                            RegionManager.default.datas[districtId] = communityArr
                        }
                    })
                    RegionManager.default.datas[regionId] = districtArr
                }
            }
            let cityId = RegionManager.default.cityId
            RegionManager.default.datas[cityId] = regionArr
        }
    }
    
    static func city() -> String {
        return RegionManager.default.city
    }
    
    static func cityId() -> Int {
        return RegionManager.default.cityId
    }
    
    static func list(_ id: Int) -> [[String : Any]] {
        return RegionManager.default.datas[id] ?? []
    }
    
    static func isEmpty() -> Bool {
        return RegionManager.default.datas.isEmpty
    }
    
    static func clear() {
        RegionManager.default.datas.removeAll()
    }
}
