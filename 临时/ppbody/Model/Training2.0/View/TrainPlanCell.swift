//
//  TrainPlanCell.swift
//  PPBody
//
//  Created by edz on 2019/12/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanCell: UITableViewCell {
    
    var handler: ((UIButton)->())?

    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLB.font = dzy_FontBlod(15)
        numLB.font = dzy_Font(10)
    }
    
    func updateUI(_ data: [String : Any], isCoach: Bool) {
        nameLB.text = data.stringValue("name")
        if isCoach {
            numLB.text = "被训练\(data.intValue("useNum") ?? 0)次"
        }else {
            numLB.text = "\(data.intValue("num") ?? 0)组动作"
        }
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        handler?(sender)
    }
}
