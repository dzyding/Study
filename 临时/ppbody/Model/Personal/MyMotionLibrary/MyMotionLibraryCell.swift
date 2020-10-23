//
//  MyMotionLibraryCell.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol MyMotionLibraryCellDeleteDelegate:NSObjectProtocol {
    func deleteAction(_ cell:MyMotionLibraryCell)
}

class MyMotionLibraryCell: UITableViewCell {

    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var useLB: UILabel!
    
    
    weak var delegate:MyMotionLibraryCellDeleteDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(data: [String: Any]) {
        nameLb.text = data["name"] as? String
        iconImg.setCoverImageUrl(data["cover"] as! String)
        self.useLB.text = "被使用\(data["useNum"] as! Int)次"
   }

    @IBAction func deleteAction(_ sender: UIButton) {
        self.delegate?.deleteAction(self)
    }

    
}
