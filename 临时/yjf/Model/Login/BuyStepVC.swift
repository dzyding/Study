//
//  BuyStepVC.swift
//  YJF
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class BuyStepVC: TrainBaseVC, TrainNextJumpProtocol {
    
    private var bottomH: CGFloat = BuyStepBottomView.fullHeight
    
    override var scrollBottomH: CGFloat {
        get {
            return bottomH
        }
        set {
            bottomH = newValue
        }
    }
    
    private var agreeBtn: UIButton {
        return bottomView.agreeBtn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "买方购买流程"
        switch type {
        case .push:
            ZKProgressHUD.show()
            PublicFunc.checkPayOrTrain(.buyTrain) { [weak self] (result, _) in
                ZKProgressHUD.dismiss()
                if !result {
                    self?.initUI()
                }else {
                    self?.bottomH = BuyStepBottomView.shortHeight
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
        if let url = URL(string: "https://www2.ejfun.com/flow-intro/buyer-flow-intro.html")
        {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func finalAction(_ firstType: TrainNextJumpType) {
        if agreeBtn.isSelected {
            PublicFunc.jumpTrainApi(10)
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

    lazy var bottomView: BuyStepBottomView = {
        let bottom = BuyStepBottomView.initFromNib(BuyStepBottomView.self)
        bottom.delegate = self
        return bottom
    }()
}

extension BuyStepVC: BuyStepBottomViewDelegate {
    func bottomView(_ bottomView: BuyStepBottomView, didClickPayDepostBtn btn: UIButton) {
        finalAction(.buyDeposit)
    }
    
    func bottomView(_ bottomView: BuyStepBottomView, didClickSureBtn btn: UIButton) {
        finalAction(.none)
    }
}
