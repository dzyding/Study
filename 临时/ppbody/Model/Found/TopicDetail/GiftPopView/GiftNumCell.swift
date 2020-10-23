//
//  GiftNumCell.swift
//  PPBody
//
//  Created by edz on 2018/12/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class GiftNumCell: UITableViewCell {
    
    var model: GiftNumModel? {
        didSet {
            updateViews()
        }
    }
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        numLB.isUserInteractionEnabled = false
        msgLB.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateViews() {
        guard let model = model else {return}
        numLB.text = model.0
        msgLB.text = model.1
        contentView.backgroundColor = model.2 ? RGB(r: 51.0, g: 50.0, b: 55.0) : RGB(r: 39.0, g: 39.0, b: 44.0)
    }
    
}
