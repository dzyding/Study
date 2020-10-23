//
//  LGymCoachCell.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LGymCoachCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var photoIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    /// -7 0
    @IBOutlet weak var nameCenterXLC: NSLayoutConstraint!
    
    @IBOutlet weak var authIV: UIImageView!
    
    @IBOutlet weak var infoLB: UILabel!
    
    @IBOutlet weak var selectIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI(_ pt: [String : Any]) {
        let selected = pt.boolValue(SelectedKey) ?? false
        bgView.layer.borderColor = YellowMainColor.cgColor
        bgView.layer.borderWidth = selected ? 1 : 0
        selectIV.isHidden = selected ? false : true
        let name = pt.stringValue("name")
        nameLB.text = name
        if name == "随机" {
            photoIV.image = UIImage(named: "reserve_coach_default")
            photoIV.contentMode = .center
        }else {
            photoIV.setCoverImageUrl(pt.stringValue("head") ?? "")
            photoIV.contentMode = .scaleAspectFill
        }
        if let departMent = pt.stringValue("departMent"),
            departMent.count > 0
        {
            infoLB.text = departMent
        }else {
            infoLB.text = "私教"
        }
        
        let auth = pt.intValue("auth") ?? 0
        if auth == 0 {
            authIV.isHidden = true
            nameCenterXLC.constant = 0
        }else {
            authIV.isHidden = false
            nameCenterXLC.constant = -7
        }
    }
}
