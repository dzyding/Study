//
//  T12GoodsImgView.swift
//  PPBody
//
//  Created by edz on 2019/11/18.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import Kingfisher

class T12GoodsImgView: UIView, InitFromNibEnable {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var heightLC: NSLayoutConstraint!
    
    func updateUI(_ img: String) {
        guard let url = URL(string: img) else {return}
        KingfisherManager.shared.downloader.downloadImage(with: url, options: [.cacheOriginalImage]) { (result) in
            switch result {
            case .success(let request):
                self.updateImageView(request.image)
            case .failure(let error):
                dzy_log(error)
            }
        }
    }
    
    private func updateImageView(_ image: UIImage) {
        self.imgView.image = image
        let size = image.size
        let height = ScreenWidth / size.width * size.height
        heightLC.constant = height
    }
}
