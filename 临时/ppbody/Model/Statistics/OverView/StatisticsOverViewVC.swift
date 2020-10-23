//
//  StatisticsOverViewVC.swift
//  PPBody
//
//  Created by edz on 2019/12/31.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class StatisticsOverViewVC: BaseVC {
    
    private let itemInfo: IndicatorInfo

    @IBOutlet weak var stackView: UIStackView!
    
    init(_ itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addArrangedSubview(timesView)
        stackView.addArrangedSubview(weekView)
        stackView.addArrangedSubview(numView)
        loadTimesData()
        loadWeekData()
    }
    
//    MARK: - api
    // 运动频次
    private func loadTimesData() {
        let request = BaseRequest()
        request.url = BaseURL.HalfYear
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let list = data?.arrValue("list") ?? []
            self.timesView.initUI(list)
        }
    }
    
    // 周数据
    private func loadWeekData() {
        let request = BaseRequest()
        request.url = BaseURL.WeekOverView
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let motionSt = data?["motionSt"] as? [Int] ?? []
            let weekSet = data?.dicValue("weekSt") ?? [:]
            self.weekView.initUI(weekSet)
            self.numView.updateUI(motionSt)
        }
    }
    
//    MARK: - 懒加载
    private lazy var timesView: SOVTimesView = {
        let view = SOVTimesView.initFromNib()
        return view
    }()
    
    private lazy var weekView: SOVWeekView = {
        let view = SOVWeekView.initFromNib()
        return view
    }()
    
    private lazy var numView: SOVNumView = {
        let view = SOVNumView.initFromNib()
        view.initUI()
        return view
    }()
}

extension StatisticsOverViewVC: IndicatorInfoProvider
{
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
}
