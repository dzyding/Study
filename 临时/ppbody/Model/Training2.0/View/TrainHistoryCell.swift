//
//  TrainHistoryCell.swift
//  PPBody
//
//  Created by edz on 2020/1/7.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TrainHistoryCell: UITableViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var iconNameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLB.font = dzy_FontBlod(13)
        numLB.font = dzy_FontBlod(11)
    }

    func updateUI(_ data: [String : Any]) {
        let type = data.intValue("type") ?? 10
        let planName = data.stringValue("planName") ?? "空"
        let num = data.intValue("totalNum") ?? 0
        nameLB.text = planName
        numLB.text = "\(num)组动作"
        assert(planName.count >= 1)
        if type == 10 {
            let end = planName.index(after: planName.startIndex)
            let name = planName[planName.startIndex..<end]
            iconNameLB.text = String(name)
            iconIV.isHidden = true
            iconNameLB.isHidden = false
        }else {
            let percent = data.doubleValue("percent") ?? 0
            numLB.text = percent == 100 ?
                "\(num)组动作·已完成" :
                "\(num)组动作·完成\(percent.decimalStr)%"
            iconIV.isHidden = false
            iconNameLB.isHidden = true
        }
    }
    
}
