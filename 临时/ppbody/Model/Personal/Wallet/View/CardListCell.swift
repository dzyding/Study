//
//  CardListCell.swift
//  PPBody
//
//  Created by edz on 2018/12/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CardListCell: UITableViewCell {
    /// logo
    @IBOutlet weak var logoIV: UIImageView!
    /// 名字
    @IBOutlet weak var nameLB: UILabel!
    /// 信息
    @IBOutlet weak var msgLB: UILabel!
    /// 是否为默认
    @IBOutlet weak var defaultIV: UIImageView!
    /// 选择按钮
    @IBOutlet weak var selBtn: UIButton!
    
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
        defaultIV.isHidden = data.intValue("status") == 20 ? false : true
        selBtn.isSelected = data.boolValue("isSelected") ?? false
        
        if let bankName = data.stringValue("bankName"),
            let model = BankListVC.data.filter({$0.name == bankName}).first
        {
            nameLB.text = bankName
            logoIV.image = UIImage(named: model.logo)
        }
        
        if let bankNo = data.stringValue("bankNo"), bankNo.count > 4,
            let realName = data.stringValue("realname"), realName.count > 1
        {
            let startIndex = realName.startIndex
            let endIndex = realName.index(after: startIndex)
            let name = realName.replacingCharacters(in: startIndex..<endIndex, with: "*")
            
            let noIndex = bankNo.index(bankNo.endIndex, offsetBy: -4)
            msgLB.text = "尾号" + bankNo[noIndex...] + "储蓄卡" + name
        }
    }
}
