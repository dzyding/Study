//
//  BarCollectionCell.swift
//  PPBody
//
//  Created by Mike on 2018/6/15.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class BarCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialization code
    }
    
    func setData(arr:[String]) {
        lblTitle.text = arr[0]
        if arr[1] == "1" {
            //表示被选中
            lblTitle.textColor = YellowMainColor
            imageV.image = UIImage.init(named: "check_select")
            imageV.contentMode = .scaleToFill
        }
        else if arr[2] == "0" {
            //默认值状态 没做更改
            lblTitle.textColor = Text1Color
            imageV.image = UIImage.init(named: "greeCircle")
            imageV.contentMode = .center
        }
        else {
            //表示齿轮值也就是默认值被改过
            lblTitle.textColor = UIColor.white
            imageV.image = UIImage.init(named: "whiteCircle")
            imageV.contentMode = .center
        }
    }
}
