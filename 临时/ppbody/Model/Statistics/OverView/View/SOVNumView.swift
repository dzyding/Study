//
//  SOVNumView.swift
//  PPBody
//
//  Created by edz on 2020/1/6.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class SOVNumView: UIView, InitFromNibEnable {

    @IBOutlet weak var stackView: UIStackView!
    
    func initUI() {
        (1...6).forEach { (index) in
            let view = SOVNumBaseView.initFromNib()
            stackView.addArrangedSubview(view)
        }
    }
    
    func updateUI(_ datas: [Int]) {
        guard let max = datas.max() else {return}
        let names = ["胸部", "背部", "肩部", "腹部", "手臂", "臀腿", "有氧"]
        stackView.arrangedSubviews.enumerated().forEach({ (index, view) in
            if let view = view as? SOVNumBaseView {
                view.updateUI(names[index], current: datas[index], total: max)
            }
        })
    }

}
