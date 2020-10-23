//
//  CustomBackProtocol.swift
//  YJF
//
//  Created by edz on 2019/7/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

protocol CustomBackProtocol where Self: UIViewController {
    func dzy_removeToFirstVC(_ pvc: UIViewController.Type, isContain: Bool)
    func dzy_removeToChildVCs(_ pvcs: [UIViewController.Type])
    func dzy_removeAllChilds()
    func dzy_removeChildVCs(_ pvcs: [UIViewController.Type])
}

extension CustomBackProtocol {
    
    private func removeBaseFunc(_ index: Int) {
        var vcs = navigationController?.viewControllers ?? []
        if index + 1 <= vcs.count - 1 { // 就是符合类型的 vc 正好就是当前 vc 的情况
            vcs.removeSubrange((index + 1)..<(vcs.count - 1))
            navigationController?
                .setViewControllers(vcs, animated: false)
        }
    }
    
    /**
     同一个 vc 在 vcs 里面有多个的情况，移除到第一个。
     或者就是明确的指定一个 vc
     
     isContain 就是是否包含该 vc
     */
    func dzy_removeToFirstVC(_ pvc: UIViewController.Type, isContain: Bool) {
        let vcs = navigationController?.viewControllers ?? []
        // 找第一个匹配的
        var resultIndex: Int?
        for (index, vc) in vcs.enumerated() {
            if type(of: vc) == pvc {
                resultIndex = index
                break
            }
        }
        if isContain,
            let value = resultIndex
        {
            resultIndex = value - 1
        }
        guard let result = resultIndex else {return}
        removeBaseFunc(result)
    }
    
    /// 将目标vc（多个中最靠近当前的一个）之后的vc全部删除
    func dzy_removeToChildVCs(_ pvcs: [UIViewController.Type]) {
        let vcs = navigationController?.viewControllers ?? []
        // 这里是为了搜索离当前 vc 最近的
        var resultIndex: Int?
        for (index, vc) in vcs.enumerated() {
            for pvc in pvcs where type(of: vc) == pvc {
                resultIndex = index
            }
        }
        guard let result = resultIndex else {return}
        removeBaseFunc(result)
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
