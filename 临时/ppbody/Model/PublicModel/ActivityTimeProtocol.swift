//
//  ActivityTimeProtocol.swift
//  PPBody
//
//  Created by edz on 2019/11/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import Foundation

protocol ActivityTimeProtocol {
    func checkActivityDate() -> Bool
}

extension ActivityTimeProtocol {
    func checkActivityDate() -> Bool {
        let today = Date()
        let startStr = "2019.12.12 00:00:00"
        let endStr = "2019.12.14 23:59:59"
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let start = dateFormat.date(from: startStr),
            let end = dateFormat.date(from: endStr)
            else {return true}
        return today.compare(start) == .orderedDescending &&
            today.compare(end) == .orderedAscending
    }
}
