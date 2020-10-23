//
//  CoachHomeMoodView.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachHomeMoodView: UIView {


    
    override func awakeFromNib() {
    }
    
    class func instanceFromNib() -> CoachHomeMoodView {
        return UINib(nibName: "PersonalPageHomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[4] as! CoachHomeMoodView
    }
    
    

}
