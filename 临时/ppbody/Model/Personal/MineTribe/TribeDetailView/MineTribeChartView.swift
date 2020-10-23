
//
//  MineTribeChartView.swift
//  PPBody
//
//  Created by Mike on 2018/7/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MineTribeChartView: UIView {

    
    @IBOutlet var headIV: [UIImageView]!
    
    @IBOutlet var nicknameLB: [UILabel]!
    
    class func instanceFromNib() -> MineTribeChartView {
        return UINib(nibName: "MineTribeDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[3] as! MineTribeChartView
    }
    
    func setData(_ rank:[[String:Any]])
    {
        for i in 0..<rank.count {
            let item = rank[i]
            self.headIV[i].setHeadImageUrl(item["head"] as! String)
            self.nicknameLB[i].text = item["nickname"] as? String
        }
    }

}
