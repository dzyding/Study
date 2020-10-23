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

extension UIImageView {
    func setCoverImageUrl(_ url: String?) {
        guard let url = url, url.count > 0 else {
            image = nil
            return
        }
        
        let path = url.replacingOccurrences(of: " ", with: "%20")
        let info = KingfisherOptionsInfo(arrayLiteral: .transition(.fade(0.4)))
        kf.setImage(with: URL(string: path), placeholder: nil, options: info)
    }
    
    func setCoverImageUrl(_ url: String,
                          complete: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?)
    {
        if url == "" {
            image = nil
            return
        }
        let path = url.replacingOccurrences(of: " ", with: "%20")
        let info = KingfisherOptionsInfo(arrayLiteral: .transition(.fade(0.4)))
        kf.setImage(with: URL(string: path), placeholder: nil, options: info, completionHandler: complete)
    }
    
    
    func setHeadImageUrl(_ url: String?) {
        guard let url = url, url.count > 0 else {
            image = nil
            return
        }
        let path = url.replacingOccurrences(of: " ", with: "%20")
        
        self.sd_setImage(with: URL(string: path), placeholderImage: DefaultHeader, options: .retryFailed, progress: nil, completed: nil)
        
//        self.kf.setImage(with: URL(string: path), placeholder: DefaultHeader, options: [.transition(.fade(0.4))], progressBlock: nil, completionHandler: nil)
    }
}
