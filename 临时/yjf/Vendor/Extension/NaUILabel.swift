//
//  NaLabel.swift
//  LaiLai
//
//  Created by Nathan_he on 2018/11/16.
//  Copyright © 2018年 Charlie. All rights reserved.
//

import Foundation
import UIKit
extension UILabel {
    //判断文本标签的内容是否被截断
    var isMoreThreeRow: Bool {
        guard let labelText = text else {
            return false
        }
        
        //计算理论上显示所有文字需要的尺寸
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelTextSize = (labelText as NSString)
            .boundingRect(with: rect, options: .usesLineFragmentOrigin,
                          attributes: [NSAttributedString.Key.font: self.font!], context: nil)
        
        //计算理论上需要的行数
        let labelTextLines = Int(ceil(CGFloat(labelTextSize.height) / self.font.lineHeight))
        
        //实际可显示的行数
        var labelShowLines = Int(floor(CGFloat(bounds.size.height) / self.font.lineHeight))
        labelShowLines = min(labelShowLines, 3)
        
        //比较两个行数来判断是否需要截断
        return labelTextLines > labelShowLines
    }
}
