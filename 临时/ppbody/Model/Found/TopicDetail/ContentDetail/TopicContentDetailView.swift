//
//  ContentDetail.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicContentDetailView: UIView {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textview: UITextView!

    @IBOutlet weak var topMargin: NSLayoutConstraint! // 55 有标签 16 无标签
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLB: UILabel!
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    
    class func instanceFromNib() -> TopicContentDetailView {
        return UINib(nibName: "TopicContentDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopicContentDetailView
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        hiden()
    }
    
    @objc func hiden()
    {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight)
        }) { (finish) in
            if finish{
                self.removeFromSuperview()
            }
        }
    }
    
    override func awakeFromNib() {
        self.bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hiden)))
    }
    
    func setData(_ dic:[String:Any])
    {
        let content = dic["content"] as! String

        self.textview.attributedText = ToolClass.rowSpaceText(content, system: 14, color: UIColor.white)
        
        let address = dic["address"] as? String
        if address != nil && !(address?.isEmpty)!
        {
            self.addressView.isHidden = false
            self.addressLB.text = address
        }else{
            self.addressView.isHidden = true
        }
        
        let tag = dic["tag"] as? String
        if tag != nil && !(tag?.isEmpty)!
        {
            self.tagView.isHidden = false
            self.tagLB.text = tag
            self.topMargin.constant = 55
        }else{
            self.tagView.isHidden = true
            self.topMargin.constant = 16

        }
        
        self.timeLB.text = ToolClass.compareCurrentTime(date: dic["createTime"] as! String)
    }
}
