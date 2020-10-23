//
//  NaPageControl.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/24.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class NaPageControl:UIPageControl
{
    let dotW = 10
    let margin = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var currentPage: Int{
        didSet{
            for iv in self.subviews
            {
                iv.frame = CGRect(x: iv.frame.origin.x, y: iv.frame.origin.y, width: 6, height: 6)
            }
        }
    }
}
