//
//  SellStepVC.swift
//  YJF
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class SellStepVC: TrainBaseVC, TrainNextJumpProtocol {
    
    private var bottomH: CGFloat = SellStepBottomView.fullHeight
    
    override var scrollBottomH: CGFloat {
        get {
            return bottomH
        }
        set {
            bottomH = newValue
        }
    }
    
    var agreeBtn: UIButton {
        return bottomView.agreeBtn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "卖方售房流程"
        switch type {
        case .push:
            ZKProgressHUD.show()
            PublicFunc.checkPayOrTrain(.sellTrain) { [weak self] (result, _) in
                ZKProgressHUD.dismiss()
                if !result {
                    self?.initUI()
                }else {
                    self?.bottomH = SellStepBottomView.shortHeight
                    self?.updateWebViewLayout()
                    self?.bottomView.updateUI()
                    self?.initUI()
                }
            }
        default:
            initUI()
        }
    }
    
    private func initUI() {
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(scrollBottomH)
            make.bottom.equalTo(view.dzyLayout.snp.bottom)
        }
        if let url = URL(string: "https://www2.ejfun.com/flow-intro/seller-flow-intro.html")
        {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func finalAction(_ firstType: TrainNextJumpType) {
        if agreeBtn.isSelected {
            PublicFunc.jumpTrainApi(20)
        }
        DataManager.saveTrainNextJump(firstType)
        switch type {
        case .login:
            let vc = BaseNavVC(rootViewController: BaseTabbarVC())
            navigationController?.present(vc, animated: true, completion: nil)
            dzy_popRoot()
        case .changeType:
            dismiss(animated: true, completion: nil)
        case .push:
            if firstType == .none {
                dzy_pop()
            }else {
                checkTarinNextJump()
            }
        }
    }
    
    //    MARK: - 懒加载
    lazy var bottomView: SellStepBottomView = {
        let bottom = SellStepBottomView.initFromNib(SellStepBottomView.self)
        bottom.delegate = self
        return bottom
    }()
}

extension SellStepVC: SellStepBottomViewDelegate {
    
    func bottomView(_ bottomView: SellStepBottomView, didClickAddHouseBtn btn: UIButton) {
        finalAction(.addHouse)
    }
    
    func bottomView(_ bottomView: SellStepBottomView, didClickSellDepositBtn btn: UIButton) {
        finalAction(.sellDeposit)
    }
    
    func bottomView(_ bottomView: SellStepBottomView, didClickSureBtn btn: UIButton) {
        finalAction(.none)
    }
}
