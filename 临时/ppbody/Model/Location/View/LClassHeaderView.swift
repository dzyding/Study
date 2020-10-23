//
//  LClassHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/10/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LClassHeaderViewDelegate: class {
    func headerView(_ headerView: LClassHeaderView,
                    didClickShopListBtn btn: UIButton)
    func headerView(_ headerView: LClassHeaderView,
                    didClickEvaluateListBtn btn: UIButton)
}

class LClassHeaderView: UIView, InitFromNibEnable {
    
    weak var delegate: LClassHeaderViewDelegate?
    
    @IBOutlet weak var stackView: UIStackView!
    
    func initUI() {
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(centerView)
        stackView.addArrangedSubview(bottomView)
    }
    
    private func shopAction(_ sender: UIButton) {
        delegate?.headerView(self, didClickShopListBtn: sender)
    }
    
    private func evaluateAction(_ sender: UIButton) {
        delegate?.headerView(self, didClickEvaluateListBtn: sender)
    }
    
//    MARK: - 懒加载
    private lazy var topView: LClassHeaderTopView = {
        let view = LClassHeaderTopView.initFromNib()
        view.initUI()
        return view
    }()
    
    private lazy var centerView: LocationPublicInfoListView = {
        let view = LocationPublicInfoListView.initFromNib()
        view.twoLBInitUI([
            ("体验时长", "60分钟"),
            ("上课人数", "1-10人"),
            ("提供服务", "可淋浴，物品寄存"),
            ("注意事项", "使用人群：18-55岁身体健康人群"),
            ("退款条件", "到达预约时间前1小时可退"),
            ("体验对象", "本店新客户")
        ], title: "体验须知")
        return view
    }()
    
    private lazy var bottomView: LClassHeaderBottomView = {
        let view = LClassHeaderBottomView.initFromNib()
        view.shopHandler = { [weak self] btn in
            self?.shopAction(btn)
        }
        view.evaluateHandler = { [weak self] btn in
            self?.evaluateAction(btn)
        }
        return view
    }()
}
