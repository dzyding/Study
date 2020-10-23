//
//  BlackListCell.swift
//  PPBody
//
//  Created by edz on 2019/10/10.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class BlackListCell: UITableViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var briefLB: UILabel!
    
    @IBOutlet weak var btn: UIButton!
    
    var handler:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        handler?()
    }
    
    func updateUI(_ data: [String : Any]) {
        iconIV.dzy_setCircleImg(data.stringValue("head") ?? "", 180)
        nameLB.text = data.stringValue("nickname")
        briefLB.text = data.stringValue("brief")
        if data.boolValue(SelectedKey) == true {
            btn.setTitle("拉黑", for: .normal)
            btn.setTitleColor(dzy_HexColor(0x27272c), for: .normal)
            btn.backgroundColor = YellowMainColor
        }else {
            btn.setTitle("解除拉黑", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = dzy_HexColor(0x333237)
        }
    }
}
