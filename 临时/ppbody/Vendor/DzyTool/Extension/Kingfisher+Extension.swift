//
//  NaUIImageView.swift
//  ZAJA_A_iOS
//
//  Created by Nathan_he on 2017/9/5.
//  Copyright © 2017年 ZHY. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

// 圆形图片
struct RoundModifier: ImageModifier {
    
    let size: CGFloat
    
    init(_ size: CGFloat) {
        self.size = size
    }
    
    func modify(_ image: Image) -> Image {
        return image.kf.image(withRoundRadius: size / 2.0, fit: CGSize(width: size, height: size))
    }
}

extension UIImage {
     func dzy_circle(_ size: CGFloat) -> UIImage {
          return kf.image(withRoundRadius: size / 2.0, fit: CGSize(width: size, height: size))
     }
}

extension UIImageView {
    func dzy_setCircleImg(_ url: String, _ size: CGFloat, placeholder: UIImage? = nil) {
        if let url = URL(string: url) {
            kf.setImage(with: url, placeholder: placeholder, options: [.cacheOriginalImage, .imageModifier(RoundModifier(size))])
        }
    }
}

extension UIButton {
    func dzy_setCircleImg(_ url: String, _ size: CGFloat, placeholder: UIImage? = nil) {
        if let url = URL(string: url) {
            kf.setImage(with: url, for: .normal, placeholder: placeholder, options: [.cacheOriginalImage, .imageModifier(RoundModifier(size))])
        }else {
            DispatchQueue.main.async {
                if let placeholder = placeholder {
                    let image = placeholder.kf.image(withRoundRadius: placeholder.size.height / 2.0, fit: placeholder.size)
                    self.setImage(image, for: .normal)
                }
            }
        }
    }
}
