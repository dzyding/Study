//
//  SetCommonCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SetCommonCell: UICollectionViewCell {
    
    var lblContent :UILabel = {
        let l = UILabel.init()
        l.font = ToolClass.CustomFont(13)
        l.textColor = UIColor.white;
        l.backgroundColor = UIColor.clear;
        l.textAlignment = .center;
        return l;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.layer.cornerRadius = 5;
        self.backgroundColor = UIColor.ColorHex("#4a4a4a");
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.size.height/2.0
        self.layer.borderWidth = 1
        self.layer.borderColor = self.backgroundColor?.cgColor
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func setUI() {
        
        self.addSubview(lblContent);
        
        lblContent.snp.makeConstraints { (maker) in
            
            maker.left.equalToSuperview().offset(0);
            maker.right.equalToSuperview().offset(0);
            maker.bottom.equalToSuperview().offset(0);
            maker.top.equalToSuperview().offset(0);
            
        }
    }
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let att = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        let text: NSString = self.lblContent.text! as NSString
        
        var newFrame = text.boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: self.lblContent.na_height), options: .usesLineFragmentOrigin, attributes:[NSAttributedString.Key.font: ToolClass.CustomFont(13)], context: nil)
        
        newFrame.size.height += 16
        newFrame.size.width += 32
        att.frame = newFrame
        return att
        
    }
}



