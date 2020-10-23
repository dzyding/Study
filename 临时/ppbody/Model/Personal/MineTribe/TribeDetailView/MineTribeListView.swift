
//
//  MineTribeListView.swift
//  PPBody
//
//  Created by Mike on 2018/7/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MineTribeListView: UIView {
    
    @IBOutlet weak var numLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func awakeFromNib() {
        stackView.spacing = (ScreenWidth - 314)/4
    }
    
    
    func setData(_ dic:[String:Any])
    {
        
        let totalNum = dic["totalMember"] as! Int
        let members = dic["members"] as! [[String: Any]]
        
        self.numLbl.text = "\(totalNum)人"
        
        for i in 0..<members.count {
            
            let user = members[i]
            
            let iv = UIImageView()
            iv.layer.cornerRadius = 25
            self.stackView.addArrangedSubview(iv)
            iv.snp.makeConstraints { (make) in
                make.width.height.equalTo(50)
            }
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds =  true
            
            if i == members.count - 1
            {
                if totalNum > members.count
                {
                    //更多
                }else{
                    iv.setHeadImageUrl(user["head"] as! String)
                }
            }else{
                iv.setHeadImageUrl(user["head"] as! String)

            }
            
        }
        
    }

    class func instanceFromNib() -> MineTribeListView {
        return UINib(nibName: "MineTribeDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[2] as! MineTribeListView
    }
}
