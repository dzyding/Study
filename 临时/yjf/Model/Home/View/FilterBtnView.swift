//
//  FilterBtnView.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class FilterBtnView: UIView {
    
    weak var titleLB: UILabel?
    
    var isSelected: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    private weak var imgIV: UIImageView?
    
    var handler: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        let titleLB = UILabel()
        titleLB.font = dzy_Font(12)
        titleLB.textColor = Font_Dark
        addSubview(titleLB)
        self.titleLB = titleLB
        
        let imgIV = UIImageView(image: UIImage(named: "sort_light_down"))
        imgIV.contentMode = .scaleAspectFit
        addSubview(imgIV)
        self.imgIV = imgIV
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        addSubview(btn)
        
        titleLB.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self).offset(-10)
            make.left.greaterThanOrEqualTo(2)
            make.right.lessThanOrEqualTo(-12)
        }
        
        imgIV.snp.makeConstraints { (make) in
            make.width.height.equalTo(5)
            make.centerY.equalTo(titleLB)
            make.left.equalTo(titleLB.snp.right).offset(5)
        }
        
        btn.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets.zero)
        }
    }
    
    private func updateUI() {
        let imageName = isSelected ? "sort_color_up" : "sort_light_down"
        let image = UIImage(named: imageName)
        imgIV?.image = image
        titleLB?.textColor = isSelected ? MainColor : Font_Dark
    }
    
    @objc private func btnAction() {
        isSelected = true
        handler?()
    }
}
