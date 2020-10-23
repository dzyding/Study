//
//  LocationPtExpDetailHeaderView.swift
//  PPBody
//
//  Created by edz on 2019/10/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationPtExpDetailHeaderView: UIView, InitFromNibEnable {

    @IBOutlet weak var stackView: UIStackView!
    
    func initUI(_ data: [String : Any]) {
        infoView.initUI(data)
        stackView.addArrangedSubview(infoView)
        
        itemsView.initUI(data)
        stackView.addArrangedSubview(itemsView)
    }
    
    private lazy var infoView: LPtExpDetailInfoView = {
        let view = LPtExpDetailInfoView.initFromNib()
        return view
    }()
    
    private lazy var itemsView = LPtExpDetailItemsView.initFromNib()
}
