//
//  DzyTableView+Extension.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

extension UITableView {
    func dzy_registerFromNib<T: UITableViewCell>(_ cls:T.Type) {
        let name = String(describing: cls)
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forCellReuseIdentifier: name)
    }
    
    func dzy_dequeue<T: UITableViewCell>(_ cls:T.Type) -> T? {
        let name = String(describing: cls)
        return dequeueReusableCell(withIdentifier: name) as? T
    }
}
