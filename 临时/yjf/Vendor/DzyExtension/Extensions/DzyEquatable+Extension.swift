//
//  DzyEquatable+Extension.swift
//  YJF
//
//  Created by edz on 2019/8/19.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

extension Equatable {
    
    func isAny(of datas: Self...) -> Bool {
        return datas.contains(self)
    }
    
}
