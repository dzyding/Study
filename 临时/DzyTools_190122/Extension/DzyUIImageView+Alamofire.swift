//
//  DzyUIImageView+Alamofire.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation
import AlamofireImage


extension UIImageView {
    func dzy_circleImg(_ url: String, size: CGFloat, placeHolder: String) {
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: size, height: size), radius: size / 2.0)
        if let Url = URL(string: url) {
            af_setImage(withURL: Url, placeholderImage: UIImage(named: placeHolder)?.af_imageRoundedIntoCircle(), filter: filter)
        }
    }
    
    func dzy_Img(_ url: String, placeHolder: String) {
        if let Url = URL(string: url) {
            af_setImage(withURL: Url, placeholderImage: UIImage(named: placeHolder))
        }
    }
}
