//
//  TrainPlanView.swift
//  PPBody
//
//  Created by edz on 2019/12/18.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol TrainPlanViewDelegate: class {
    func planView(_ planView: TrainPlanView, didClickPlan plan: [String : Any])
}

class TrainPlanView: UIView, InitFromNibEnable {
    
    weak var delegate: TrainPlanViewDelegate?

    @IBOutlet weak var mTitleLB: UILabel!
    @IBOutlet weak var selfBtn: UIButton!
    
    @IBOutlet weak var stackViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mTitleLB.font = dzy_FontBBlod(16)
        selfBtn.titleLabel?.font = dzy_FontBlod(15)
        selfBtn.layer.borderWidth = 1
        selfBtn.layer.borderColor = YellowMainColor.cgColor
        selfBtn.layer.cornerRadius = 6
        selfBtn.layer.masksToBounds = true
    }
    
    func initUI(_ datas: [[String : Any]]) {
        let count = datas.count
        while stackView.arrangedSubviews.count > 0 {
            stackView.arrangedSubviews
                .first?.removeFromSuperview()
        }
        guard count > 0 else {
            stackViewHeightLC.constant = 0
            return
        }
        stackViewHeightLC.constant = 65 * CGFloat(count) + 10 * CGFloat(count - 1)
        (0..<count).forEach { (index) in
            let view = TrainPlanListView.initFromNib()
            view.initUI(datas[index])
            view.handler = { [unowned self] in
                self.delegate?.planView(self, didClickPlan: datas[index])
            }
            stackView.addArrangedSubview(view)
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        let vc = TrainPlanVC()
        parentVC?.dzy_push(vc)
    }
    
    @IBAction func selfAction(_ sender: Any) {
        let vc = PlanSelectMotionVC(.one)
        parentVC?.dzy_push(vc)
    }
    
}
