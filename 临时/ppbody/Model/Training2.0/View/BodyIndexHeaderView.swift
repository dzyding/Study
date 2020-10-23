//
//  BodyIndexHeaderView.swift
//  PPBody
//
//  Created by edz on 2020/5/18.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class BodyIndexHeaderView: UIView, InitFromNibEnable {

    @IBOutlet weak var mTitleLB: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    private var type: BodyStatusType = .Fat
    
    var height: CGFloat = 462
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mTitleLB.font = dzy_FontBlod(15)
    }
    
    func initUI(_ type: BodyStatusType) {
        self.type = type
        if lineView.superview == nil {
            stackView.insertArrangedSubview(lineView, at: 0)
        }
        switch type {
        case .Weight, .Muscle, .Fat:
            if currentView.superview == nil {
                stackView.insertArrangedSubview(currentView, at: 1)
            }
            // 50 260 152
            height = 462
        default:
            // 50 260
            height = 310
        }
        frame = CGRect(x: 0, y: 0,
                       width: ScreenWidth, height: height)
    }
    
    func initValues(_ type: BodyStatusType,
                  min: Double,
                  max: Double,
                  low: Double,
                  high: Double,
                  current: Double,
                  unit: String)
    {
        currentView.updateUI(type, min: min, max: max, low: low, high: high, current: current, unit: unit)
    }
    
    func updateUI(_ list: [[String : Any]]) {
        if list.count == 1 {
            if lineView.superview != nil {
                lineView.removeFromSuperview()
            }
            height = 50.0
        }else {
            initUI(type)
        }
        guard list.count > 1 else {return}
        lineView.updateUI(list)
    }
    
//    MARK: - 懒加载
    private lazy var lineView = BIHLineView.initFromNib()
    
    private lazy var currentView = BIHCurrentView.initFromNib()
}
