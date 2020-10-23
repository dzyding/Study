//
//  CoachCourseVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachCourseVC: ButtonBarPagerTabStripViewController {

    var isReload = false
    
    lazy var historyBtn: UIButton = {
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        rightBtn.setTitle("历史", for: .normal)
        rightBtn.setTitleColor(Text1Color, for: .normal)
        rightBtn.titleLabel?.font = ToolClass.CustomFont(15)
        rightBtn.addTarget(self, action: #selector(historyAction), for: .touchUpInside)
        rightBtn.sizeToFit()
        return rightBtn
    }()
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        
        settings.style.selectedBarBackgroundColor = YellowMainColor
        super.viewDidLoad()
        
        self.title = "课程排期"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.historyBtn)
        
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
    
    @objc func historyAction() {
        let vc = CourseHistoryListVC()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func addCourse(_ sender: UIButton) {
        let vc = CoachAddCourseVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = CoachCourseChildVC(itemInfo: "今")
        let child_2 = CoachCourseChildVC(itemInfo: "明")
        let child_3 = CoachCourseChildVC(itemInfo: "后")
        
        guard isReload else {
            return [child_1, child_2, child_3]
        }
        
        var childViewControllers = [child_1, child_2,child_3]
        
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
    
}
