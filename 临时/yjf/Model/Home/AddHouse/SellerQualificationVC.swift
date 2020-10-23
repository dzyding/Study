//
//  ConfirmSellerQualificationVC.swift
//  YJF
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SellerQualificationVC: BaseVC {
    
    @IBOutlet weak var firstBtn: UIButton!
    
    @IBOutlet weak var secondBtn: UIButton!
    
    private let house: [String : Any]
    
    init(_ house: [String : Any]) {
        self.house = house
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "售房资格确认"
        view.backgroundColor = dzy_HexColor(0xF5F5F5)
    }
    
    @IBAction func selectActon(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        guard firstBtn.isSelected else {
            showMessage("请确认房产是否被查封")
            return
        }
        guard secondBtn.isSelected else {
            showMessage("请确认是否获取出售资格")
            return
        }
        PublicFunc.userOperFooter(.sellVerify)
        let vc = ImageVerifyVC(house)
        dzy_push(vc)
    }
}
