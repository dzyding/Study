//
//  EvaluateStarView.swift
//  YJF
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol EvaluateStarViewDelegate {
    func starView(_ starView: EvaluateStarView, didSelectRank rank: Int)
}

class EvaluateStarView: UIView {
    
    weak var delegate: EvaluateStarViewDelegate?

    @IBOutlet private weak var stackView: UIStackView!
    
    //    MARK: - 选择星级
    @IBAction private func starAction(_ sender: UIButton) {
        updateUI(sender.tag + 1)
    }
    
    func updateUI(_ rank: Int) {
        (0..<stackView.arrangedSubviews.count).forEach { (index) in
            guard let btn = stackView.arrangedSubviews[index] as? UIButton else {return}
            if index < rank {
                btn.isSelected = true
            }else {
                btn.isSelected = false
            }
        }
        delegate?.starView(self, didSelectRank: rank)
    }
}
