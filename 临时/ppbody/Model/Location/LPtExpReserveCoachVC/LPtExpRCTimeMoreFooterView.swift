//
//  LocationRCTimeMoreFooterView.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpRCTimeMoreFooterView: UICollectionReusableView {
    
    var handler: (()->())?
    
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var arrowIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ isSelected: Bool) {
        btn.isSelected = isSelected
        updateTitle()
    }
    
    @IBAction private func btnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        handler?()
        updateTitle()
    }
    
    private func updateTitle() {
        if btn.isSelected {
            titleLB.text = "收起"
            arrowIV.image = UIImage(named: "lgym_arrrow_top")
        }else {
            titleLB.text = "更多时间"
            arrowIV.image = UIImage(named: "lgym_arrrow_bottom")
        }
    }
}
