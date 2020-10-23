//
//  MyCoach.swift
//  PPBody
//
//  Created by edz on 2019/4/18.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyCoachVC: ButtonBarPagerTabStripViewController {
    
    var isReload = false
    
    private let info: [String : Any]
    
    init(_ info: [String : Any]) {
        self.info = info
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        settings.style.selectedBarBackgroundColor = YellowMainColor
        super.viewDidLoad()
        navigationItem.title = info.stringValue("name") ?? info.stringValue("ptName")
        navigationItem.rightBarButtonItem = rightBtn
        
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
        // 交叉预约为 staffId，非交叉为 ptId
        guard let ptId = info.intValue("ptId") ?? info.intValue("staffId") else {return []}
        let child_1 = MyCoachBaseVC(ptId, itemInfo: IndicatorInfo(title: "今"))
        let child_2 = MyCoachBaseVC(ptId, itemInfo: IndicatorInfo(title: "明"))
        let child_3 = MyCoachBaseVC(ptId, itemInfo: IndicatorInfo(title: "后"))
        
        guard isReload else {
            return [child_1, child_2, child_3]
        }
        
        var childViewControllers = [child_1, child_2, child_3]
        
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
    
//    MARK: - 核销历史
    @objc private func historyAction() {
        let vc = MyCourseHistoryVC()
        dzy_push(vc)
    }
    
//    MARK: - 懒加载
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 75, height: 35)
        btn.setTitle("核销历史记录", for: .normal)
        btn.titleLabel?.font = dzy_Font(12)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self,
                      action: #selector(historyAction),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}
