//
//  StudentCourseVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class StudentCourseVC: ButtonBarPagerTabStripViewController {

    var isReload = false
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        
        settings.style.selectedBarBackgroundColor = YellowMainColor
        super.viewDidLoad()
        
        self.navigationItem.title = "我的课程"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)

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
        // Do any additional setup after loading the view.
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = StudentCourseChildVC(itemInfo: "待学习")
        let child_2 = StudentCourseChildVC(itemInfo: "已学习")
        
        guard isReload else {
            return [child_1, child_2]
        }
        
        var childViewControllers = [child_1, child_2]
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
