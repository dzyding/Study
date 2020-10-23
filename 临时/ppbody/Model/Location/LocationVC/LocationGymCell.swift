//
//  LocationGymCell.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGymCell: UITableViewCell {
    /// 2 + 38 * num
    @IBOutlet weak var bottomLC: NSLayoutConstraint!
    @IBOutlet weak var activityIV: UIImageView!
    /// logo
    @IBOutlet weak var logoIV: UIImageView!
    /// 名字
    @IBOutlet weak var nameLB: UILabel!
    /// 地址
    @IBOutlet weak var addressLB: UILabel!
    /// 类型
    @IBOutlet weak var typeLB: UILabel!
    /// 距离
    @IBOutlet weak var distanceLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var lineIV: UIView!
    
    private lazy var topCell = LocationGymInfoSubCell.initFromNib()
    
    private lazy var bottomCell = LocationGymInfoSubCell.initFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.addArrangedSubview(topCell)
        stackView.addArrangedSubview(bottomCell)
    }
    
    func updateUI(_ data: [String : Any]) {
        let count = updateSubViews(data)
        lineIV.isHidden = count == 0
        bottomLC.constant = 2 + 38.0 * CGFloat(count)
        
        activityIV.isHidden = data.intValue("activity12") != 1
        let url = data.stringValue("logo") ?? data.stringValue("cover")
        if let url = url,
            url.count > 0
        {
            logoIV.setCoverImageUrl(url)
        }else {
            logoIV.image = nil
        }
        nameLB.text = data.stringValue("name")
        addressLB.text = data.stringValue("region")
        data.doubleValue("distance")
            .map({$0/1000})
            .flatMap({
                distanceLB.text = "距\($0.decimalStr)km"
            })
        data.intValue("type").flatMap({
            typeLB.text = LocationVCHelper.gymStrType($0)
        })
    }
    
    private func updateSubViews(_ data: [String : Any]) -> Int {
        topCell.hide()
        bottomCell.hide()
        let groupBuy = data.dicValue("groupBuy") ?? [:]
        let groupBuyNum = data.intValue("groupBuyNum") ?? 0
        let ptExp = data.dicValue("ptExp") ?? [:]
        let ptExpNum = data.intValue("ptExpNum") ?? 0
        var count = 0
        if groupBuy.count > 0,
            ptExp.count > 0
        {
            count = 2
            topCell.groupBuyUpdateUI(groupBuy, count: groupBuyNum)
            bottomCell.ptExpUpdateUI(ptExp, count: ptExpNum)
        }else if groupBuy.count > 0 {
            count = 1
            topCell.groupBuyUpdateUI(groupBuy, count: groupBuyNum)
        }else if ptExp.count > 0 {
            count = 1
            topCell.ptExpUpdateUI(ptExp, count: ptExpNum)
        }
        return count
    }
}
