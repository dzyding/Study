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

// 占位图的名字
fileprivate let placeholderName = "temp"

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
    func dzy_setCircleImg(_ url: String, _ size: CGFloat) {
        if let url = URL(string: url) {
            kf.setImage(with: url, placeholder: Image(named: placeholderName), options: [.cacheOriginalImage, .imageModifier(RoundModifier(size))])
        }
    }
         
    func setCoverImageUrl(_ url: String?, complete: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        if let url = url, url.count > 0 {
            let path = url.replacingOccurrences(of: " ", with: "%20")
            kf.setImage(with: URL(string: path), options: [.transition(.fade(0.4))], completionHandler: complete)
        }
    }
}

extension UIButton {
    func dzy_setCircleImg(_ url: String, _ size: CGFloat, placeholder: UIImage? = UIImage(named: placeholderName)) {
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
    
    func dzy_setImg(_ url: String, placeholder: UIImage? = UIImage(named: placeholderName), _ state: UIControl.State = .normal) {
        if let url = URL(string: url) {
            kf.setImage(with: url, for: state, placeholder: placeholder)
        }
    }
}
