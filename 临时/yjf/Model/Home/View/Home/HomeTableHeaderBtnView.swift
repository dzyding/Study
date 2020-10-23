//
//  HomeTableHeaderBtnView.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HomeTableHeaderBtnView: UIView {

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    private var type: FunType = .howLook
    
    var handler: ((FunType) -> ())?
    
    //swiftlint:disable:next large_tuple
    func updateUI(_ model: (String, String, FunType)) {
        titleLB.text = model.0
        iconIV.image = UIImage(named: model.1)
        self.type = model.2
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        handler?(type)
    }
}
