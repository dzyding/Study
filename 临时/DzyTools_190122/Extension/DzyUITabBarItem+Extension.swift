//
//  DzyUITabBarItem+Extension.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

extension UITabBarItem {
    fileprivate func alwaysOriginalImg(_ name: String) -> UIImage? {
        if let img = UIImage(named: name) {
            return img.withRenderingMode(.alwaysOriginal)
        }else {
            return nil
        }
    }
    
    func dzy_image(normal: String, selected: String) {
        image = alwaysOriginalImg(normal)
        selectedImage = alwaysOriginalImg(selected)
    }
    
    func dzy_imageSame(img: String) {
        image = alwaysOriginalImg(img)
        selectedImage = alwaysOriginalImg(img)
    }
}
