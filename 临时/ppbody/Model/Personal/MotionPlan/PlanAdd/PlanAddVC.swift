//
//  PlanAddVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PlanAddVC: BaseVC {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scvContent: UIScrollView!
    
    private lazy var msgView = AddPlanMsgView.initFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "新增自定义计划"
        stackView.addArrangedSubview(msgView)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        guard let info = msgView.msg() else {return}
        for (k,v) in info {
            dataDic[k] = v
        }
        //新增自定义计划
        let vc = PlanSelectMotionVC(.newPlan)
        vc.dataDic = dataDic
        dzy_push(vc)
    }
}
