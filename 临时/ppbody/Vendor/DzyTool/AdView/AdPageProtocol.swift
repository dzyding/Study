//
//  AdPageProtocol.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol AdPageProtocol: class {
    var pageNum: Int {get set}
    
    var currentPage: Int {get set}
    
    func updatePage(_ currentNum: Int)
}
