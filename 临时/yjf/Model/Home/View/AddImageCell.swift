//
//  AddImageCell.swift
//  YJF
//
//  Created by edz on 2019/5/9.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol AddImageCellDelegate {
    func imageCell(_ imageCell: AddImageCell, didClickDelBtn btn: UIButton)
}

class AddImageCell: UICollectionViewCell {
    
    weak var delegate: AddImageCellDelegate?
    
    var indexPath: IndexPath?

    @IBOutlet private weak var imgView: UIImageView!
    
    @IBOutlet private weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI(_ image: (UIImage?, String?)?, indexPath: IndexPath) {
        self.indexPath = indexPath
        if let image = image?.0 {
            imgView.image = image
            deleteBtn.isHidden = false
        }else if let url = image?.1 {
            imgView.setCoverImageUrl(url)
            deleteBtn.isHidden = false
        }else{
            imgView.image = UIImage(named: "watch_add_img")
            deleteBtn.isHidden = true
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        delegate?.imageCell(self, didClickDelBtn: sender)
    }
}
