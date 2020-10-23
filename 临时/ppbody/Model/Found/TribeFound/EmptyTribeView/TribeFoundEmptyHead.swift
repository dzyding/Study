
//
//  TribeFoundEmptyHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/17.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TribeFoundEmptyHead: UIView {
    
    class func instanceFromNib() -> TribeFoundEmptyHead {
        return UINib(nibName: "TribeFoundEmptyHead", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TribeFoundEmptyHead
    }
    
}
