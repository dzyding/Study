//
//  CoachGymClassView.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol CoachGymClassViewDelegate {
    func classView(_ classView: CoachGymClassView, didSelectMoreBtn btn: UIButton)
}

class CoachGymClassView: UIView {
    
    @IBOutlet weak var emptyIV: UIImageView!
    
    weak var delegate: CoachGymClassViewDelegate?
    
    @IBOutlet weak var stackView: UIStackView!
    
    func updateUI(_ list: [[String : Any]]) {
        if list.count == 0 {
            emptyIV.isHidden = false
        }else {
            emptyIV.isHidden = true
            list.forEach { model in
                let view = CoachGymClassBaseView
                    .initFromNib(CoachGymClassBaseView.self)
                view.updateUI(model)
                stackView.addArrangedSubview(view)
            }
        }
    }
    
    @IBAction func modelAction(_ sender: UIButton) {
        delegate?.classView(self, didSelectMoreBtn: sender)
    }
}
