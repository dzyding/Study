//
//  LocationGBDetailHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/10/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGBDetailHeaderView: UIView, InitFromNibEnable {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var evaluateView: UIView!
    /// 共368条评论
    @IBOutlet weak var numLB: UILabel!
    
    var handler: (()->())?
    
    @IBAction func moreAction(_ sender: Any) {
        handler?()
    }
    
    func updateUI(_ data: [String : Any]) {
        let comments = data.dicValue("comments")?
            .arrValue("list") ?? []
        let totalCount = data.dicValue("comments")?
            .dicValue("page")?
            .intValue("totalNum") ?? 0
        numLB.text = "共\(totalCount)条评论"
        evaluateView.isHidden = comments.count == 0
        
        infoView.updateUI(data)
        stackView.addArrangedSubview(infoView)
        
        itemsView.updateUI(data)
        stackView.addArrangedSubview(itemsView)
        
        let useNum = data.intValue("useNum") ?? 1
        var endStr = ""
        if let endTime = data.stringValue("endTime")?
            .components(separatedBy: " ").first,
            endTime.count > 0
        {
            endStr = endTime
        }
        if endStr.count == 0,
            let endDay = data.intValue("endDay")
        {
            endStr = "购买后\(endDay)天有效"
        }
        var setting: [(String, String)] = [
            ("有效期", endStr),
            ("使用时间", data.stringValue("useTime") ?? ""),
            ("适用人数", "每张团购券最多\(useNum)人使用"),
            ("规则提醒", data.stringValue("rule") ?? ""),
            ("温馨提示", "如需团购券发票，请您在消费时向商户咨询")
        ]
        // 1 需预约
        if data.intValue("isOrder") == 1 {
            setting.insert(("预约信息", data.stringValue("orderInfo") ?? ""), at: 2)
        }
        noticeView.twoLBInitUI(setting, title: "购买须知")
        stackView.addArrangedSubview(noticeView)
    }
    
    /// 评价
    @IBAction func evaluateAction(_ sender: UIButton) {
        
    }
    
    //    MARK: - 懒加载
    /// 团购的顶部视图
    private lazy var infoView: LocationGBInfoView = {
        let view = LocationGBInfoView.initFromNib()
        return view
    }()
    
    private lazy var noticeView: LocationPublicInfoListView = {
        let view = LocationPublicInfoListView.initFromNib()
        return view
    }()
    
    private lazy var itemsView: LocationGBItemsView = {
        let view = LocationGBItemsView.initFromNib()
        return view
    }()
}
