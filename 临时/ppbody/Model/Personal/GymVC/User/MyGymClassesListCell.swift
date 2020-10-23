//
//  MyGymClassesListCell.swift
//  PPBody
//
//  Created by edz on 2019/11/21.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyGymClassesListCell: UITableViewCell {

    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        let cla = data.dicValue("clubClass")
        nameLB.text = cla?.stringValue("name")
        numLB.text = "\(data.intValue("num") ?? 0)"
        if let time = data.stringValue("endTime")?
            .components(separatedBy: " ").first
        {
            timeLB.text = "（\(time)截止）"
        }else {
            timeLB.text = nil
        }
    }
}
