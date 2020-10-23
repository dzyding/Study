//
//  MyGymCardView.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyGymCardView: UIView {

    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var valueLB: UILabel!
    
    @IBOutlet weak var subNameLB: UILabel!
    
    @IBOutlet weak var subValueLB: UILabel!
    
    func setUI(_ card: [String : Any]) {
        subNameLB.isHidden = true
        subValueLB.isHidden = true
        
        let type = card.intValue("type") ?? 0
        typeLB.text = card.stringValue("name")
        switch type {
        case 10:
            nameLB.text = "截止至"
            valueLB.text = card.stringValue("endTime")
        case 20:
            nameLB.text = "剩余次数"
            valueLB.text = "\(card.intValue("num") ?? 0)"
        case 21:
            subNameLB.isHidden = false
            subValueLB.isHidden = false
            
            nameLB.text = "截止至"
            valueLB.text = card.stringValue("endTime")
            subNameLB.text = "剩余次数"
            subValueLB.text = "\(card.intValue("num") ?? 0)"
        case 30:
            nameLB.text = "剩余金额"
            valueLB.text = "\(card.intValue("amount") ?? 0)元"
        default:
            break
        }
    }

}
