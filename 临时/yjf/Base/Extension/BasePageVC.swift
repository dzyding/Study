//
//  BasePageVC.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

// 支持分页的BaseVC
class BasePageVC: BaseVC, PageEnable {
    
    var dataArr: [[String : Any]] = []
    
    var page: [String : Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
