//
//  DzyOptional+Extension.swift
//  YJF
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

//extension Optional where Wrapped == String {
//    var isEorN: Bool {
//        switch self {
//        case let string?:
//            return string.isEmpty
//        case nil:
//            return true
//        }
//    }
//}

extension Optional where Wrapped: Collection {
    /// empty or nil
    var isEorN: Bool {
        switch self {
        case let collection?:
            return collection.isEmpty
        case nil:
            return true
        }
    }
}
