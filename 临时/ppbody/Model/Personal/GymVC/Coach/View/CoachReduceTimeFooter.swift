//
//  CoachReduceTimeFooter.swift
//  PPBody
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceTimeFooter: UIView {
    
    var handler: (()->())?

    @IBAction func newAction(_ sender: UIButton) {
        handler?()
    }
}
