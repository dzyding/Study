//
//  MyCollectVC.swift
//  PPBody
//
//  Created by edz on 2019/11/2.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum CollectType {
    case gym
    case good
    
    func title() -> String {
        switch self {
        case .gym:
            return "健身房"
        case .good:
            return "商品"
        }
    }
}

class MyCollectVC: ButtonBarPagerTabStripViewController {
    
    private var isReload = false

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        settings.style.selectedBarBackgroundColor = YellowMainColor
        super.viewDidLoad()
        navigationItem.title = "我的收藏"
        setUI()
    }

    private func setUI() {
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = Text1Color
            newCell?.label.textColor = YellowMainColor
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            } else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let arr: [CollectType] = [.gym, .good]
        let vcs: [UIViewController] = arr.map({MyCollectBaseVC($0)})
        
        guard isReload else {
            return vcs
        }
        
        var childViewControllers = vcs
        
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
}
