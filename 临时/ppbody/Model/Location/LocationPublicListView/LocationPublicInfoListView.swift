//
//  LocationPublicInfoListView.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
/// 购买须知
class LocationPublicInfoListView: UIView, InitFromNibEnable {

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    func twoLBColorInitUI(_ datas: [(String, String, UIColor)],
                          title: String,
                          spacing: CGFloat = 8.0
    ) {
        titleLB.text = title
        stackView.spacing = spacing
        datas.forEach { (value) in
            let view = LocationPITwoLBView.initFromNib()
            view.colorUpdateUI(value)
            stackView.addArrangedSubview(view)
        }
//        stackView.setNeedsLayout()
//        stackView.layoutIfNeeded()
    }
    
    func twoLBInitUI(_ datas: [(String, String)],
                title: String,
                spacing: CGFloat = 8.0
    ) {
        titleLB.text = title
        stackView.spacing = spacing
        datas.forEach { (value) in
            let view = LocationPITwoLBView.initFromNib()
            view.updateUI(value)
            stackView.addArrangedSubview(view)
        }
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
    }
    
    func onwLBInitUI(_ datas: [String],
                     title: String,
                     spacing: CGFloat = 8.0)
    {
        titleLB.text = title
        stackView.spacing = spacing
        datas.forEach { (value) in
            let view = LocationPIOneLBView.initFromNib()
            view.updateUI(value)
            stackView.addArrangedSubview(view)
        }
        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
    }
}
