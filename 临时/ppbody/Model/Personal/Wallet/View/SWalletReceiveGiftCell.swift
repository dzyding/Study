//
//  WalletReceiveGiftCell.swift
//  PPBody
//
//  Created by edz on 2018/12/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SWalletReceiveGiftCell: UITableViewCell {

    @IBOutlet weak var personIconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var giftIconIV: UIImageView!
    
    @IBOutlet weak var numLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    var data: [String : Any]? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateViews() {
        guard let data = data else {return}
        let user = data.dicValue("user")
        personIconIV.setCoverImageUrl(user?.stringValue("head") ?? "")
        giftIconIV.setCoverImageUrl(data.dicValue("gift")?.stringValue("cover") ?? "")
        nameLB.text = user?.stringValue("nickname") ?? user?.stringValue("realname")
        timeLB.text = ToolClass.compareCurrentTime(date: data.stringValue("createTime") ?? Date().description)
        
        let numStr = "x\(data.intValue("num") ?? 0)"
        let attStr = NSMutableAttributedString(string: numStr, attributes: [
            NSAttributedString.Key.font : ToolClass.CustomFont(17),
            NSAttributedString.Key.foregroundColor : UIColor.white
            ])
        attStr.addAttributes([
            NSAttributedString.Key.font : ToolClass.CustomFont(13)
            ], range: NSRange(location: 0, length: 1))
        numLB.attributedText = attStr
    }
}
