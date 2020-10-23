//
//  RectPageController.swift
//  YJF
//
//  Created by edz on 2019/4/25.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class RectPageController: UIView, AdPageProtocol {
    
    private weak var stackView: UIStackView?
    
    internal var pageNum: Int = 0
    
    var currentPage: Int = 0
    
    var normalColor = dzy_HexColor(0xDFDFDF)
    
    var currentColor = dzy_HexColor(0x262626)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        let stackView = UIStackView(frame: bounds)
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 6.0
        addSubview(stackView)
        self.stackView = stackView
    }
    
    func updateUI(_ pageNum: Int) {
        self.pageNum = pageNum
        (0..<pageNum).forEach { (index) in
            let view = UIView()
            let color = index == currentPage ? currentColor : normalColor
            view.backgroundColor = color
            stackView?.addArrangedSubview(view)
        }
    }
    
    func updatePage(_ currentNum: Int) {
        self.currentPage = currentNum
        (0..<pageNum).forEach { (index) in
            let color = index == currentNum ? currentColor : normalColor
            stackView?.subviews[index].backgroundColor = color
        }
    }
}
