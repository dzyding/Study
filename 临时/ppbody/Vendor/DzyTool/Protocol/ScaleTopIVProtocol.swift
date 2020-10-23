//
//  ScaleTopIVProtocol.swift
//  PPBody
//
//  Created by edz on 2018/12/6.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol ScaleTopIVProtocol {
    /// 需放大视图的高度 (并不一定等于 iv 的高度)
    var ivHeight: CGFloat {get}
    /// 需放大视图
    var scaleIV: UIImageView {get}
    /// 向上滑动的时候是否需要隐藏
    var ifHidden: Bool {get}
    /// 主要的缩放方法
    func sacleFunction(_ offsetY: CGFloat)
}

extension ScaleTopIVProtocol {
    
    var ifHidden: Bool {
        return false
    }
    
    func sacleFunction(_ offsetY: CGFloat) {
        if offsetY > 0 {
            let x = offsetY / ivHeight
            let trans = CGAffineTransform(translationX: 0, y: offsetY / 4)
            let scale = CGAffineTransform(scaleX: 1 + x, y: 1 + x)
            scaleIV.transform = scale.concatenating(trans)
        }else if offsetY > -ivHeight {
            if ifHidden {scaleIV.isHidden = false}
            scaleIV.transform = CGAffineTransform(translationX: 0, y: offsetY / 2.0)
        }else {
            if ifHidden {scaleIV.isHidden = true}
        }
    }
}
