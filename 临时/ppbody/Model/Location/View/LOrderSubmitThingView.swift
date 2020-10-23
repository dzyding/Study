//
//  LOrderSubmitThingView.swift
//  PPBody
//
//  Created by edz on 2019/10/26.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LOrderSubmitThingViewDelegate: class {
    func thingView(_ thingView: LOrderSubmitThingView,
                   didChangeNum num: Int)
}

class LOrderSubmitThingView: UIView, InitFromNibEnable, AttPriceProtocol, ActivityTimeProtocol {
    
    weak var delegate: LOrderSubmitThingViewDelegate?

    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var priceLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    private lazy var isActivity: Bool = checkActivityDate()
    
    private var num: Int {
        guard let numStr = numLB.text,
            let num = Int(numStr)
        else {
            return 1
        }
        return num
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateUI(_ data: [String : Any]) {
        nameLB.text = data.stringValue("name")
        if isActivity,
            let aprice = data.doubleValue("activityPrice"),
            aprice > 0
        {
            priceLB.attributedText = attPriceStr(aprice)
        }else {
            let price = data.doubleValue("presentPrice") ?? 0
            priceLB.attributedText = attPriceStr(price)
        }
    }
    
    @IBAction private func reduceAction(_ sender: UIButton) {
        guard let numStr = numLB.text,
            let num = Int(numStr),
            num > 1
        else {
            return
        }
        numLB.text = "\(num - 1)"
        delegate?.thingView(self, didChangeNum: num - 1)
    }
    
    @IBAction private func addAction(_ sender: Any) {
        guard let numStr = numLB.text,
            let num = Int(numStr)
        else {
            return
        }
        numLB.text = "\(num + 1)"
        delegate?.thingView(self, didChangeNum: num + 1)
    }
}
