//
//  RecordItemView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/24.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RecordItemView: UIView
{
    @IBOutlet weak var head: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    class func instanceFromNib() -> RecordItemView {
        return UINib(nibName: "TrainingItemView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! RecordItemView
    }
    
    override func awakeFromNib() {
        
    }
    
    func setData(_ dic: [String:Any]) {
        self.head.setCoverImageUrl(dic["cover"] as? String ?? "")
        self.name.text = dic["name"] as? String
    }
    
    func setCoachData(_ dic: [String:Any])
    {
        self.head.setCoverImageUrl(dic["head"] as! String)
        self.name.text = dic["nickname"] as? String
    }

}
