//
//  TrainPlanEditListCell.swift
//  PPBody
//
//  Created by edz on 2019/12/20.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanEditListCell: UITableViewCell {

    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var nameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLB.font = dzy_FontBlod(15)
    }
    
    func updateUI(_ type: Int, data: [String : Any]) {
        let iname = type == 0 ? "train_plan_list_remove" : "train_plan_list_add"
        btn.setImage(UIImage(named: iname), for: .normal)
        nameLB.text = data.stringValue("name")
    }
}
