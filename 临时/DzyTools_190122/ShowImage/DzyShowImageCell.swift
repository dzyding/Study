//
//  DzyShowImageCell.swift
//  171026_Swift图片展示
//
//  Created by 森泓投资 on 2017/10/26.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

fileprivate let Space: CGFloat = 10  //集合显示时的间隔

let kDzyShowImageCell = "DzyShowImageCell"

class DzyShowImageCell: UICollectionViewCell {
    
    fileprivate weak var scrollView: DzyShowImageScrollView?
    
    var handler: (() -> ())? {
        didSet {
            scrollView?.handler = handler
        }
    }
    
    var url: String? {
        didSet {
            scrollView?.url = url
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setSubViews() {
        let frame = CGRect(x: Space, y: 0.0, width: dzy_SW, height: dzy_SH)
        let scrollView = DzyShowImageScrollView(frame: frame)
        contentView.addSubview(scrollView)
        self.scrollView = scrollView
    }
}

