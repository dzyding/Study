//
//  LocationOrderVC.swift
//  PPBody
//
//  Created by edz on 2019/10/31.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationOrderVC: ButtonBarPagerTabStripViewController {
    
    private var isReload = false

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        settings.style.selectedBarBackgroundColor = YellowMainColor
        super.viewDidLoad()
        navigationItem.title = "团购订单"
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
        let arr: [LOrderType] = [.all, .pay, .use, .evaluate, .end]
        let vcs: [UIViewController] = arr.map({LocationOrderBaseVC($0)})
        
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
