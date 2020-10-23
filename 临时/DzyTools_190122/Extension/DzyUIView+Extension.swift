//
//  DzyUIView+Extension.swift
//  HousingMarket
//
//  Created by dzy_PC on 2018/11/26.
//  Copyright © 2018年 远坂凛. All rights reserved.
//

import UIKit

extension UIView {
    static func initFromNib<T: UIView>(_ type: T.Type) -> T {
        let name = String(describing: type)
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil).first as! T
    }
    
    func dzy_shadow(_ color: UIColor, _ opacity: Float = 0.5, _ raidus: CGFloat = 2) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = raidus
        layer.shadowOffset = CGSize.zero
        
        /*
         offset 的 x 是控制左右的， y 是控制 上下的
         raidus 宽度
        */
    }
}
