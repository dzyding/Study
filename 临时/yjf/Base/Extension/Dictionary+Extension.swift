//
//  Dictionary+Extension.swift
//  PPBody
//
//  Created by dzy_PC on 2018/11/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

extension Dictionary where Dictionary.Key == String {
    func stringValue(_ key: String) -> String? {
        return self[key] as? String
    }
    
    func intValue(_ key: String) -> Int? {
        return self[key] as? Int
    }
    
    func doubleValue(_ key: String) -> Double? {
        return self[key] as? Double
    }
    
    func boolValue(_ key: String) -> Bool? {
        return self[key] as? Bool
    }
    
    func dicValue(_ key: String) -> [String : Any]? {
        return self[key] as? [String : Any]
    }
    
    func arrValue(_ key: String) -> [[String : Any]]? {
        return self[key] as? [[String : Any]]
    }
}
