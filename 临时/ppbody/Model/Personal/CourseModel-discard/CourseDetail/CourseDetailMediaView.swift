//
//  CourseDetailMediaView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class CourseDetailMediaView: UIView{
    
    @IBOutlet weak var subBtn: UIButton!
    @IBOutlet weak var coverIV: UIImageView!
    @IBOutlet weak var playIV: UIImageView!
    
    var deleteBlock:((UIView) -> ())?
    
    class func instanceFromNib() -> CourseDetailMediaView {
        return UINib(nibName: "CourseDetailMediaView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CourseDetailMediaView
    }
    
    @IBAction func subAction(_ sender: UIButton) {
        self.deleteBlock?(self)
    }
}
