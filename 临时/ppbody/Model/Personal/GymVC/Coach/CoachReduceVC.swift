//
//  CoachReduceVC.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum CoachReduceTimeType {
    case current    //本周
    case next       //下周
}

class CoachReduceVC: ButtonBarPagerTabStripViewController {
    
    private var config: [String : Any] = [:]
    
    private var isReload = false
    
    private var isFirst = true
    
    private let type: CoachReduceTimeType
    
    init(_ type: CoachReduceTimeType) {
        self.type = type
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
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ptConfigApi()
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
    
    //    MARK: - 预约设置
    func settingAction() {
        let vc = CoachReduceSettingVC(config)
        dzy_push(vc)
    }
    
    @IBAction func setReduceAction(_ sender: UIButton) {
        if let duration = config.intValue("duration"),
            duration > 0
        {
            let vc = CoachSetClassVC(config)
            dzy_push(vc)
        }else {
            ToolClass.showToast("请前往设置界面，设置课时长", .Failure)
        }
    }
    
    //    MARK: - 滚动框架相关方法
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var vcs: [UIViewController] = []
        
        let calendar = Calendar.current
        let now = Date()
        var todayWeek = calendar.component(.weekday, from: now)
        todayWeek = todayWeek == 1 ? 7 : todayWeek - 1
        
        switch type {
        case .current:
            (1...7).forEach { (week) in
                let x = week - todayWeek
                var component = DateComponents()
                component.day = x
                let date = calendar.date(byAdding: component, to: now) ?? Date()
                let item = IndicatorInfo(title: getTitle(week, ifToday: x == 0))
                let vc = CoachReduceBaseVC(item, date: date, x: x)
                vcs.append(vc)
            }
        case .next:
            // 今天距离下个星期一的间距
            var x = 7 - todayWeek
            (1...7).forEach { (week) in
                x += 1
                var component = DateComponents()
                component.day = x
                let date = calendar.date(byAdding: component, to: now) ?? Date()
                let item = IndicatorInfo(title: getTitle(week, ifToday: x == 0))
                let vc = CoachReduceBaseVC(item, date: date, x: x)
                vcs.append(vc)
            }
        }
        
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
    
    //    MARK: - 将 WeekInt 转换成 String
    private func getTitle(_ week: Int, ifToday: Bool) -> String {
        if ifToday {return "今日"}
        switch week {
        case 1:
            return "周一"
        case 2:
            return "周二"
        case 3:
            return "周三"
        case 4:
            return "周四"
        case 5:
            return "周五"
        case 6:
            return "周六"
        default:
            return "周日"
        }
    }
    
    //    MARK: - 计算今天星期几，并跳转
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getWeekAndScroll()
    }
    
    private func getWeekAndScroll() {
        if !isFirst || type == .next {return}
        isFirst = false
        let calendar = Calendar.current
        var week = calendar.component(.weekday, from: Date())
        week = week == 1 ? 7 : week - 1
        let indexPath = IndexPath(item: week - 1, section: 0)
        if week != 1 {
            hightLightRow = week - 1
            collectionView(buttonBarView, didSelectItemAt: indexPath)
        }
    }
    
    //    MARK: - api
    private func ptConfigApi() {
        let request = BaseRequest()
        request.url = BaseURL.PtConfig
        request.isSaasPt = true
        request.start { (data, error) in
            self.config = data?.dicValue("config") ?? [:]
        }
    }
}
