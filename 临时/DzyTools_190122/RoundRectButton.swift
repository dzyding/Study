//
//  RoundRectButton.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/21.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import UIKit
@IBDesignable
class RoundRectButton: UIButton {
    @IBInspectable var cornerRadius:CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderColor:UIColor = .white{
        didSet{
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
