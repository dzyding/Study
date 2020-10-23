//
//  DealAffirmVC.swift
//  YJF
//
//  Created by edz on 2019/6/20.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class DealAffirmVC: BaseVC {
    
    private let houseId: Int
    
    var bidVC: BidVC?
    
    init(_ houseId: Int) {
        self.houseId = houseId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "买方购房资格确认书"
    }
    
    deinit {
        bidVC = nil
        dzy_log("销毁")
    }
    
    @IBAction func sureAction(_ sender: Any) {
        PublicFunc.userOperFooter(
            .buyZiGe, houseId: houseId
        )
        if let bidVC = bidVC {
            dzy_push(bidVC)
        }else {
            if DataManager.isPwd() == true {
                let vc = CertificationVC()
                dzy_push(vc)
            }else {
                let vc = EditMyInfoVC(.notice)
                dzy_push(vc)
            }
        }
    }
}
