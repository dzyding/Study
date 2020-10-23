//
//  AddressBookCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class AddressBookCell: UITableViewCell
{
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var bodyLB: UILabel!
    @IBOutlet weak var remarkLB: UILabel!
    
    func setData(_ model: StudentUserModel)
    {
        self.headIV.setCoverImageUrl(model.head!)
        self.nameLB.text = model.remark != nil ? model.remark : model.name
        self.bodyLB.text = model.body
        
        if model.remark != nil
        {
            self.remarkLB.text = "(" + model.name! + ")"
            self.remarkLB.isHidden = false

        }else{
            self.remarkLB.isHidden = true
        }
    }
}
