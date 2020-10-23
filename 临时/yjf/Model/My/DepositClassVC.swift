//
//  DepositClassVC.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class DepositVC: BaseVC {
    /// 第一个选择按钮
    @IBOutlet weak var firstTypeNameBtn: UIButton!
    
    @IBOutlet weak var firstTypeMoneyLB: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var firstBtn: UIButton?
    
    weak var thirdBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUI() {
        scrollView.contentSize = CGSize(width: 3 * ScreenWidth, height: 1)
        for index in (0..<3) {
            let view = UIView()
            view.backgroundColor = dzy_HexColor(0xf5f5f5)
            scrollView.addSubview(view)
            
            if index != 1 {
                let btn = UIButton(type: .custom)
                btn.backgroundColor = MainColor
                btn.layer.cornerRadius = 3
                btn.layer.masksToBounds = true
                btn.titleLabel?.font = dzy_FontBlod(16)
                view.addSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.left.equalTo(30)
                    make.right.equalTo(-30)
                    make.height.equalTo(49)
                    make.bottom.equalTo(-40)
                }
                index == 0 ? (firstBtn = btn) : (thirdBtn = btn)
            }
            
            view.snp.makeConstraints { (make) in
                make.left.equalTo(CGFloat(index) * ScreenWidth)
                make.top.bottom.equalTo(0)
                make.width.equalTo(ScreenWidth)
            }
        }
    }
}
