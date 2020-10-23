//
//  CustomBackProtocol.swift
//  YJF
//
//  Created by edz on 2019/7/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol CustomBackProtocol where Self: UIViewController {
    func dzy_removeToChildVCs(_ pvcs: [UIViewController.Type])
    func dzy_removeAllChilds()
    func dzy_removeChildVCs(_ pvcs: [UIViewController.Type])
}

extension CustomBackProtocol {
    /// 将目标vc之后的vc全部删除
    func dzy_removeToChildVCs(_ pvcs: [UIViewController.Type]) {
        var vcs = navigationController?.viewControllers ?? []
        func removeBaseFunc(_ index: Int) {
            if index + 1 <= vcs.count - 1 { // 就是符合类型的 vc 正好就是当前 vc 的情况
                vcs.removeSubrange((index + 1)..<(vcs.count - 1))
                navigationController?
                    .setViewControllers(vcs, animated: false)
            }
        }
        for (index, vc) in vcs.enumerated() {
            for pvc in pvcs where type(of: vc) == pvc {
                removeBaseFunc(index)
                return
            }
        }
    }
    
    /// 删除除了第一个以外的全部vc
    func dzy_removeAllChilds() {
        var vcs = navigationController?.viewControllers ?? []
        vcs.removeSubrange(1..<(vcs.count - 1))
        navigationController?
            .setViewControllers(vcs, animated: false)
    }
    
    /// 删除指定vc
    func dzy_removeChildVCs(_ pvcs: [UIViewController.Type]) {
        var vcs = navigationController?.viewControllers ?? []
        pvcs.forEach { (vc) in
            if let index = vcs.firstIndex(where: {type(of: $0) == vc}) {
                vcs.remove(at: index)
            }
        }
        navigationController?
            .setViewControllers(vcs, animated: true)
    }
}
