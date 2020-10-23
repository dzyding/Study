//
//  MyBidBaseVC.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MyBidBaseVC: ScrollBtnVC {
    
    override var normalFont: UIFont {
        return dzy_FontBlod(13)
    }
    
    override var selectedFont: UIFont {
        return dzy_FontBlod(15)
    }
    
    override var normalColor: UIColor {
        return dzy_HexColor(0x646464)
    }
    
    override var selectedColor: UIColor {
        return dzy_HexColor(0x262626)
    }
    
    override var btnsViewHeight: CGFloat {
        return 44
    }
    
    override var lineToBottom: CGFloat {
        return 8
    }
    
    override var isPaddingLine: Bool {
        return true
    }
    
    override var paddingLineColor: UIColor {
        return dzy_HexColor(0xe5e5e5)
    }
    
    override var titles: [String] {
        return ["竞买中", "已成交"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的竞买"
        navigationItem.rightBarButtonItem = rightNaviItem
        updateVCs()
    }
    
    override func getVCs() -> [UIViewController] {
        return [MyBiddingVC(), MyBiddedVC()]
    }
    
    override func btnsViewDidClick(_ index: Int) {
        super.btnsViewDidClick(index)
        index == 1 ?
            (navigationItem.rightBarButtonItem = nil) :
            (navigationItem.rightBarButtonItem = rightNaviItem)
    }
    
    //    MARK: - 批量操作
    @objc private func batchAction() {
        if let vc = children.first as? MyBiddingVC {
            vc.batchAction()
        }
    }
    
    //    MARK: - 懒加载
    lazy var rightNaviItem: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle("批量取消", for: .normal)
        btn.setTitleColor(Font_Dark, for: .normal)
        btn.titleLabel?.font = dzy_Font(13)
        btn.addTarget(self, action: #selector(batchAction), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}
