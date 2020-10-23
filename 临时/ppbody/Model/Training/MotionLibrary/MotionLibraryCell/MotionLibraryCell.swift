//
//  MotionLibraryCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol MotionLibraryCellDelegate: NSObjectProtocol {
    func detailAction(_ cell: MotionLibraryCell)
}

class MotionLibraryCell: UITableViewCell {
    
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
    var motion:[String:Any]?
    
    weak var delegate:MotionLibraryCellDelegate?
    
    func setData(_ dic: [String:Any]) {
        self.iconIV.setCoverImageUrl(dic["cover"] as! String)
        self.nameLB.text = dic["name"] as? String
        
        motion = dic
    }
    
    override func awakeFromNib() {
        self.iconIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(motionDetailAction(_:))))
    }
    
    @IBAction func motionDetailAction(_ sender: UIButton) {
        self.delegate?.detailAction(self)
    }

}
