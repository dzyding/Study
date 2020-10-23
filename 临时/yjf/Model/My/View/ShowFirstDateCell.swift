//
//  ShowFirstDateCell.swift
//  YJF
//
//  Created by edz on 2019/6/21.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class ShowFirstDateCell: UITableViewCell {
    
    @IBOutlet weak var dateLB: UILabel!
    
    @IBOutlet weak var dayLB: UILabel!
    
    @IBOutlet weak var moneyLB: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        func getTime(_ key: String) -> String {
            if let temp = data.stringValue(key) {
                return String(temp[...temp.index(temp.startIndex, offsetBy: 9)])
            }else {
                return ""
            }
        }
        let start = getTime("startTime")
        let end = getTime("endTime")
        dateLB.text = start + " ~ " + end

        dayLB.text = "\(data.intValue("topNum") ?? 0)天"
        moneyLB.text = String(
            format: "-%.2lf元", data.doubleValue("price") ?? 0
        )
    }
}
