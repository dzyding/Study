//
//  PrivateTrainDetailCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PrivateTrainDetailCell: UITableViewCell {
    
    @IBOutlet weak var imgMotion: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblOne: UILabel!
    @IBOutlet weak var lblTwo: UILabel!
    @IBOutlet weak var lblThree: UILabel!
    @IBOutlet weak var imgRight: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = BackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
