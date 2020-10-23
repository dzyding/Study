//
//  SearchKeyCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/31.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class SearchKeyCell: UICollectionViewCell {
    
    var lblContent :UILabel = {
        let l = UILabel.init()
        l.font = ToolClass.CustomFont(13)
        l.textColor = Text1Color
        l.backgroundColor = UIColor.clear
        l.textAlignment = .center
        return l;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = CardColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 14
 
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
