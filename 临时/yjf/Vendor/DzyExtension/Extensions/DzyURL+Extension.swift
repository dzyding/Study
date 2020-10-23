//
//  DzyURL+Extension.swift
//  YJF
//
//  Created by edz on 2019/8/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        guard let url = URL(string: "\(value)") else {
            preconditionFailure("This url: \(value) is not invalid")
        }
        self = url
    }
}
