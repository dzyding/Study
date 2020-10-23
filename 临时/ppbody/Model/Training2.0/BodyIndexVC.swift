//
//  BodyIndexVC.swift
//  PPBody
//
//  Created by edz on 2020/5/18.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

enum BodyStatusType: String {
    ///体重
    case Weight = "体重"
    ///骨骼肌
    case Muscle = "骨骼肌"
    ///体脂肪
    case Fat = "体脂肪"
    ///胸围
    case Bust = "胸围"
    ///臂围
    case Arm = "臂围"
    ///腿围
    case Thigh = "腿围"
    ///腰围
    case Waist = "腰围"
    ///臀围
    case Hipline = "臀围"
}

class BodyIndexVC: ButtonBarPagerTabStripViewController {
    
    private var isReload = false
    
    private var isOther = false

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        settings.style.selectedBarBackgroundColor = YellowMainColor
        super.viewDidLoad()
        navigationItem.title = "身材指标"
        setUI()
        
        //判断是否是学员
        if DataManager.memberInfo() != nil {
            isOther = true
            let member = DataManager.memberInfo()
            title = member!["nickname"] as! String + "的体态数据"
        }
        getBodyData()
    }
    
    private func updateUI(_ data: [String : Any]?) {
        guard let body = data?.dicValue("body") else {
            return
        }
        viewControllers.enumerated().forEach { (index, vc) in
            if index == 0 {
                (vc as? BodyStatusFirstVC)?.setBodyData(body)
            }else {
                (vc as? BodyIndexBaseVC)?.initValues(body)
            }
        }
    }
    
//    MAKR: - api
    private func getBodyData() {
        let request = BaseRequest()
        if isOther {
            request.isOther = true
        }else{
            request.isUser = true
        }
        request.url = BaseURL.BodyData
        request.start { (data, error) in
            guard error == nil else{
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.updateUI(data)
        }
    }
    
//    MARK: - UI
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

    //    MARK: - 滚动框架相关方法
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var vcs: [UIViewController] = [BodyStatusFirstVC("基本")]
        
        vcs.append(contentsOf: [
            BodyStatusType.Weight,
            BodyStatusType.Muscle,
            BodyStatusType.Fat,
            BodyStatusType.Bust,
            BodyStatusType.Hipline,
            BodyStatusType.Waist,
            BodyStatusType.Arm,
            BodyStatusType.Thigh
        ].map({
            BodyIndexBaseVC($0)
        }))
        
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
