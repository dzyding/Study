//
//  CoachReduceTimeCell.swift
//  PPBody
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceTimeCell: UITableViewCell {
    
    var delHandler: (()->())?

    @IBOutlet weak var timeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func updateUI(_ time: (Int, Int)) {
        timeLB.text = ToolClass.getTimeStr(time.0) + "-" + ToolClass.getTimeStr(time.1)
    }
    
    @IBAction func delAction(_ sender: UIButton) {
        delHandler?()
    }
}
