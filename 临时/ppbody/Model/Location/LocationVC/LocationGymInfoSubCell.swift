//
//  LocationGymInfoSubCell.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGymInfoSubCell: UIView, InitFromNibEnable, ActivityTimeProtocol {

    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var memoLB: UILabel!
    
    private lazy var isActivity: Bool = checkActivityDate()
    
    func hide() {
        (0..<subviews.count).forEach { (index) in
            subviews[index].isHidden = true
        }
    }
    
    private func show() {
        (0..<subviews.count).forEach { (index) in
            subviews[index].isHidden = false
        }
    }
        
    func groupBuyUpdateUI(_ data: [String : Any], count: Int) {
        show()
        LocationVCHelper.groupBuyLB(&typeLB!)
        nameLB.text = data.stringValue("name")
        if isActivity,
            let aprice = data.doubleValue("activityPrice"),
            aprice > 0
        {
            priceLB.text = aprice.decimalStr + "元"
        }else {
            priceLB.text = "\(data.doubleValue("presentPrice"), optStyle: .price)元"
        }
        memoLB.text = "等\(count)个团购"
    }
    
    func ptExpUpdateUI(_ data: [String : Any], count: Int) {
        show()
        LocationVCHelper.ptExpLB(&typeLB!)
        nameLB.text = data.stringValue("name")
        priceLB.text = "\(data.doubleValue("presentPrice"), optStyle: .price)元"
        memoLB.text = "等\(count)个体验课"
    }
}
