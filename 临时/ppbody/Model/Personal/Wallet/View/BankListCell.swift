//
//  BankListCell.swift
//  PPBody
//
//  Created by edz on 2018/12/18.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class BankListCell: UITableViewCell {

    @IBOutlet weak var logoIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = RGB(r: 51.0, g: 50.0, b: 55.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updata(_ model: BankModel) {
        nameLB.text = model.name
        logoIV.image = UIImage(named: model.logo)
    }
}
