//
//  InitFromNibEnableProtocol.swift
//  YJF
//
//  Created by edz on 2019/8/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol InitFromNibEnable where Self: UIView {
    static func initFromNib() -> Self
}

extension InitFromNibEnable {
    static func initFromNib() -> Self {
        let name = String(describing: self)
        return UINib(nibName: name, bundle: nil)
            .instantiate(withOwner: self, options: nil)
            .first as! Self
    }
}
