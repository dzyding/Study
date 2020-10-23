//
//  MyHouseVC.swift
//  YJF
//
//  Created by edz on 2019/5/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class MyHouseVC: ScrollBtnVC {
    
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
    
    override var bottomHeight: CGFloat {
        return isiPhoneXScreen() ? 76.0 : 110.0
    }
    
    override var titles: [String] {
        return ["在售", "历史"]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的房源"
        setBottomView()
        updateVCs()
    }
    
    override func getVCs() -> [UIViewController] {
        return [MySellingHouseVC(), MyHouseHistoryVC()]
    }
    
    @objc private func addAction() {
        let vc = AddHouseBaseVC(RegionManager.cityId())
        dzy_push(vc)
    }
    
    private func setBottomView() {
        let bottomView = UIView()
        bottomView.backgroundColor = dzy_HexColor(0xf5f5f5)
        view.addSubview(bottomView)
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle("添加房源", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.backgroundColor = MainColor
        sureBtn.titleLabel?.font = dzy_FontBlod(16)
        sureBtn.layer.cornerRadius = 3
        sureBtn.layer.masksToBounds = true
        sureBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        bottomView.addSubview(sureBtn)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(110.0)
        }
        
        sureBtn.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(49)
            make.bottom.equalTo(-40)
        }
    }
}
