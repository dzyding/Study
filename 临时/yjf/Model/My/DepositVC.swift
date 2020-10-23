//
//  DepositClassVC.swift
//  YJF
//
//  Created by edz on 2019/5/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class DepositVC: BaseVC {

    let type: Identity
    /// 第一个选择按钮
    @IBOutlet weak var firstTypeNameBtn: UIButton!
    
    @IBOutlet weak var firstTypeMoneyBtn: UIButton!
    /// 第二个选择按钮
    @IBOutlet weak var secondTypeNameBtn: UIButton!
    
    @IBOutlet weak var secondTypeMoneyBtn: UIButton!
    /// 第三个选择按钮
    @IBOutlet weak var thirdTypeNameBtn: UIButton!
    
    @IBOutlet weak var thirdTypeMoneyBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    init(_ type: Identity) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        updateThirdMoneyBtn("0元", str2: "")
    }
    
    //    MARK: - 按钮的点击事件
    @IBAction func indexAction(_ sender: UIButton) {
        changeBtnsType(sender.tag, isScroll: true)
    }
    
    //    MARK: - 更改按钮的状态
    private func changeBtnsType(_ tag: Int, isScroll: Bool) {
        if tag == 0 {
            firstTypeNameBtn.isSelected = true
            firstTypeMoneyBtn.isSelected = true
            secondTypeNameBtn.isSelected = false
            secondTypeMoneyBtn.isSelected = false
            thirdTypeNameBtn.isSelected = false
            thirdTypeMoneyBtn.isSelected = false
        }else if tag == 1 {
            firstTypeNameBtn.isSelected = false
            firstTypeMoneyBtn.isSelected = false
            secondTypeNameBtn.isSelected = true
            secondTypeMoneyBtn.isSelected = true
            thirdTypeNameBtn.isSelected = false
            thirdTypeMoneyBtn.isSelected = false
        }else {
            firstTypeNameBtn.isSelected = false
            firstTypeMoneyBtn.isSelected = false
            secondTypeNameBtn.isSelected = false
            secondTypeMoneyBtn.isSelected = false
            thirdTypeNameBtn.isSelected = true
            thirdTypeMoneyBtn.isSelected = true
        }
        if isScroll {
            let point = CGPoint(x: CGFloat(tag) * ScreenWidth, y: 0)
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    //    MARK: - 页面的基础设置
    private func setUI() {
        scrollView.contentSize = CGSize(width: 3 * ScreenWidth, height: 1)
        dzy_adjustsScrollViewInsets(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        var types: [DepositType] = []
        switch type {
        case .buyer:
            types = [.buy_look, .buy_flow, .buy_deposit]
            navigationItem.title = "买方保证金"
            firstTypeNameBtn.setTitle("看房押金", for: .normal)
        case .seller:
            types = [.sell_lock, .sell_flow, .sell_deposit]
            navigationItem.title = "卖方保证金"
            firstTypeNameBtn.setTitle("门锁押金", for: .normal)
        }
        types.enumerated().forEach { (index, type) in
            let vc = DepositContentVC(type)
            addChild(vc)
            if let view = vc.view {
                view.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(view)
                view.snp.makeConstraints { (make) in
                    make.top.height.equalTo(scrollView)
                    make.left.equalTo(CGFloat(index) * ScreenWidth)
                    make.width.equalTo(ScreenWidth)
                }
            }
        }
    }
    
    func updateUI(_ amount: [String : Any]) {
        var firstKey = ""
        var flowKey = ""
        var depositKey = ""
        var numKey = ""
        switch type {
        case .buyer:
            firstKey = "buyLookPrice"
            depositKey = "buyCashDeposit"
            numKey = "buyCashNum"
            flowKey = "buyTradingRevenue"
        case .seller:
            firstKey = "sellLookPrice"
            depositKey = "sellCashDeposit"
            numKey = "sellCashNum"
            flowKey = "sellTradingRevenue"
        }
        let num = amount.intValue(numKey) ?? 0
        firstTypeMoneyBtn.setTitle(
            "\(amount.doubleValue(firstKey), optStyle: .price)元", for: .normal
        )
        secondTypeMoneyBtn.setTitle(
            "\(amount.doubleValue(flowKey), optStyle: .price)元",
            for: .normal
        )
        let str1 = "\(amount.doubleValue(depositKey), optStyle: .price)元"
        let str2 = num > 0 ? "\(num)份" : ""
        updateThirdMoneyBtn(str1, str2: str2)
        
    }
    
//    private func intChineseStr(_ num: Int) -> String {
//        var chineseNums = [
//            "零", "壹", "贰", "叁", "肆", "伍",
//            "陆", "柒", "捌", "玖", "拾"
//        ]
//        if num <= 10 {
//            return chineseNums[num % 11] + "份"
//        }else {
//            // 个位
//            let a = num % 10
//            // 十位
//            let b = num / 10
//            return chineseNums[b % 10] + "拾" + chineseNums[a % 10]
//        }
//    }
    
    //    MARK: - 更改第三个金额按钮的显示状态
    private func updateThirdMoneyBtn(_ str1: String, str2: String) {
        let nAttStr = NSMutableAttributedString(string: str1 + str2, attributes: [
            NSAttributedString.Key.font : dzy_FontBlod(13),
            NSAttributedString.Key.foregroundColor : dzy_HexColor(0x646464)
            ])
        nAttStr.addAttributes([
            NSAttributedString.Key.font : dzy_Font(10),
            NSAttributedString.Key.foregroundColor : dzy_HexColor(0xa3a3a3)
            ], range: NSRange(location: str1.count, length: str2.count))
        thirdTypeMoneyBtn.setAttributedTitle(nAttStr, for: .normal)
        
        let sAttStr = NSMutableAttributedString(string: str1 + str2, attributes: [
            NSAttributedString.Key.font : dzy_FontBlod(13),
            NSAttributedString.Key.foregroundColor : dzy_HexColor(0x262626)
            ])
        sAttStr.addAttributes([
            NSAttributedString.Key.font : dzy_Font(10),
            NSAttributedString.Key.foregroundColor : dzy_HexColor(0xa3a3a3)
            ], range: NSRange(location: str1.count, length: str2.count))
        thirdTypeMoneyBtn.setAttributedTitle(sAttStr, for: .selected)
    }
}

extension DepositVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / ScreenWidth)
        changeBtnsType(index, isScroll: false)
    }
}
