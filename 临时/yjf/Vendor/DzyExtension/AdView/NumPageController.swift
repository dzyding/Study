//
//  NumPageController.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class NumPageController: UIView, AdPageProtocol {
    
    private weak var label: UILabel?
    
    internal var pageNum: Int = 1
    
    var currentPage: Int = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .clear
        let label = UILabel(frame: bounds)
        label.textColor = .white
        label.font = dzy_Font(10)
        label.textAlignment = .right
        addSubview(label)
        self.label = label
    }
    
    func updateUI(_ pageNum: Int) {
        self.pageNum = pageNum
        label?.text = "\(currentPage + 1)/\(pageNum)"
    }
    
    func updatePage(_ currentNum: Int) {
        currentPage = currentNum
        label?.text = "\(currentPage + 1)/\(pageNum)"
    }
}
