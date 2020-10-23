//
//  NaPrice.swift
//  ZAJA_Agent
//
//  Created by Nathan_he on 2016/12/17.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation

extension Int {
    
    var compressValue : String
    {
        if self/10000 > 1
        {
            let temp = Float(self)/Float(10000)
            
            let str = String.init(format: "%.0f", temp)
            
            return str + "W"
        }else{
            return "\(self)"
        }
    }
}

extension Float {
    
    /** 战斗力值转换 */
    var combatValues: String {
        
        if (self / 100000000) > 1 {
            
            let temp = self / 100000000
            
            if fmodf(Float(temp), 1) == 0 {
                
                let str = String.init(format: "%.0f", temp)
                
                return str + "亿"
                
            }else if fmodf(Float(temp) * 10, 1) == 0 {
                
                let str = String.init(format: "%.1f", temp)
                
                return str + "亿"
                
            }else{
                
                let str = String.init(format: "%.2f", temp)
                
                let decimal = str.components(separatedBy: ".")
                
                let arrayString = decimal[1]
                
                if arrayString == "00" {
                    
                    return decimal[0] + "亿"
                }
                
                return str + "亿"
                
            }
            
        }
        
        if (self / 10000) > 1 {
            
            let temp = self / 10000
            
            if fmodf(Float(temp), 1) == 0 {
                
                let str = String.init(format: "%.0f", temp)
                
                return str + "万"
                
            }else if fmodf(Float(temp) * 10, 1) == 0 {
                
                let str = String.init(format: "%.1f", temp)
                
                return str + "万"
                
            }else{
                
                let str = String.init(format: "%.2f", temp)
                
                let decimal = str.components(separatedBy: ".")
                
                let arrayString = decimal[1]
                
                if arrayString == "00" {
                    
                    return decimal[0] + "万"
                }
                
                return str + "万"
                
            }
            
        }
        
        if self < 10000
        {
            let temp = self
            
            if fmodf(Float(temp), 1) == 0 {
                
                let str = String.init(format: "%.0f", temp)
                
                return str + "元"
                
            }else if fmodf(Float(temp) * 10, 1) == 0 {
                
                let str = String.init(format: "%.1f", temp)
                
                return str + "元"
                
            }else{
                
                let str = String.init(format: "%.2f", temp)
                
                let decimal = str.components(separatedBy: ".")
                
                let arrayString = decimal[1]
                
                if arrayString == "00" {
                    
                    return decimal[0] + "元"
                }
                
                return str + "元"
                
            }
        }
        
//        let decimal = String.init(self).components(separatedBy: ".")
//        
//        let arrayString = decimal[1]
//        
//        if arrayString == "0" {
//            
//            return decimal[0] + "元"
//        }
        
        return String.init(self)
        
    }
    
    //去除小数点的算法
    var removeDecimalPoint: String
    {
        if fmodf(self, 1) == 0 {
            
            let str = String.init(format: "%.0f", self)
            
            return str
            
        }else if fmodf(self * 10, 1) == 0 {
            
            let str = String.init(format: "%.1f", self)
            
            return str
            
        }else{
            
            let str = String.init(format: "%.1f", self)
            
            let decimal = str.components(separatedBy: ".")
            
            let arrayString = decimal[1]
            
            if arrayString == "00" {
                
                return decimal[0]
            }
            
            return str
            
        }

    }
    
    func format(f: Int) -> Float {
        return Float(String(format: "%.\(f)f", self))!
    }
    
}

extension Double{
    func formatStr(f: Int) -> String {
        
        return String(format: "%.\(f)f", self)
    }
    
    func roundTo(places:Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
        
    }
    
    func format(f: Int) -> Double {
        return Double(String(format: "%.\(f)f", self))!
    }
    
    var removeDecimalPoin: String
    {
        if fmod(self, 1) == 0 {
            
            let str = String.init(format: "%.0f", self)
            
            return str
            
        }else {
            
            let str = String.init(format: "%.1f", self)
            
            return str
            
        }
    }
}
