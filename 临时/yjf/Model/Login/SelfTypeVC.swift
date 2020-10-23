//
//  SelfTypeVC.swift
//  YJF
//
//  Created by edz on 2019/4/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class SelfTypeVC: BaseVC {
    
    private let type: TrainStepFrom
    
    init(_ type: TrainStepFrom) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择身份"
    }
    
    private func finalAction() {
        switch type {
        case .login:
            let vc = BaseNavVC(rootViewController: BaseTabbarVC())
            present(vc, animated: true, completion: nil)
            dzy_popRoot()
        case .changeType:
            dismiss(animated: true, completion: nil)
        case .push:
            break
        }
    }
    
    @IBAction func buyTypeAction(_ sender: Any) {
        switch type {
        case .login:
            IDENTITY = .buyer
            PublicFunc.changeIdentityApi(10)
        case .changeType:
            if IDENTITY != .buyer {
                PublicFunc.changeIdentityApi(10)
            }
            IDENTITY = .buyer
        case .push:
            break
        }
        
        ZKProgressHUD.show()
        PublicFunc.checkPayOrTrain(.buyTrain) { (result, _) in
            ZKProgressHUD.dismiss()
            if result == false {
                let vc = BuyStepVC(self.type)
                self.dzy_push(vc)
            }else {
                self.finalAction()
            }
        }
    }
    
    @IBAction func sellTypeAction(_ sender: Any) {
        switch type {
        case .login:
            IDENTITY = .seller
            PublicFunc.changeIdentityApi(20)
        case .changeType:
            if IDENTITY != .seller {
                PublicFunc.changeIdentityApi(20)
            }
            IDENTITY = .seller
        case .push:
            break
        }

        ZKProgressHUD.show()
        PublicFunc.checkPayOrTrain(.sellTrain) { (result, _) in
            ZKProgressHUD.dismiss()
            if result == false {
                let vc = SellStepVC(self.type)
                self.dzy_push(vc)
            }else {
                self.finalAction()
            }
        }
    }
    
}
