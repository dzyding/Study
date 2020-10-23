//
//  VideoRateSelectView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class VideoRateSelectView: UISegmentedControl {
    
    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup()
    {
        self.backgroundColor = UIColor.ColorHexWithAlpha("#000000", 0.5)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.black], for: .selected)
        
        self.setBackgroundImage(ToolClass.createImage(UIColor.ColorHexWithAlpha("#000000", 0.5)), for: .normal, barMetrics: .default)
        self.setBackgroundImage(ToolClass.createImage(UIColor.white), for: .selected, barMetrics: .default)
        self.setBackgroundImage(ToolClass.createImage(UIColor.white), for: .highlighted, barMetrics: .default)
        
        self.setDividerImage(ToolClass.createImage(UIColor.ColorHexWithAlpha("#000000", 0.5)), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
    
}
