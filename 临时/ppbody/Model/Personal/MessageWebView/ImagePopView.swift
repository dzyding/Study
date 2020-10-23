//
//  ImagePopView.swift
//  PPBody
//
//  Created by edz on 2019/1/2.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class ImagePopView: UIView {

    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let long = UILongPressGestureRecognizer(target: self, action: #selector(saveImage(_:)))
        addGestureRecognizer(long)
        isUserInteractionEnabled = true
    }

    @objc func saveImage(_ long: UILongPressGestureRecognizer) {
        if long.state == .began,
            let image = imgView.image
        {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.save(img:didFinishSaving:contextInfo:)), nil)
            if let popView = superview as? DzyPopView {
                popView.hide()
            }
        }
    }
    
    @objc func save(img: UIImage, didFinishSaving error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        guard error == nil else {
            ToolClass.showToast("保存失败", .Failure)
            return
        }
        ToolClass.showToast("保存成功", .Success)
    }
}
