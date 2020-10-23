//
//  StatisticsMotionView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsMotionVC: ButtonBarPagerTabStripViewController {
    var isReload = false
    
    override func viewDidLoad() {
        navigationItem.title = "训练统计"
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        
        settings.style.selectedBarBackgroundColor = YellowMainColor
        
        super.viewDidLoad()
        
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
        let child_0 = StatisticsOverViewVC("概览")
        let child_1 = StatisticsDataVC(itemInfo: "胸部")
        let child_2 = StatisticsDataVC(itemInfo: "背部")
        let child_3 = StatisticsDataVC(itemInfo: "肩部")
        let child_4 = StatisticsDataVC(itemInfo: "腹部")
        let child_5 = StatisticsDataVC(itemInfo: "手臂")
        let child_6 = StatisticsDataVC(itemInfo: "臀腿")
        let child_7 = StatisticsDataVC(itemInfo: "有氧")
        
        guard isReload else {
            return [child_0, child_1, child_2, child_3, child_4, child_5, child_6, child_7]
        }
        
        var childViewControllers = [child_0, child_1, child_2, child_3, child_4, child_5, child_6, child_7]
        
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
