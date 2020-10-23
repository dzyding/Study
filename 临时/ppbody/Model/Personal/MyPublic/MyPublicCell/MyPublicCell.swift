//
//  MyPublicCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation



class MyPublicCell: UITableViewCell {
    
    @IBOutlet weak var dayLB: UILabel!
    @IBOutlet weak var monthLB: UILabel!
    @IBOutlet weak var coverview: MyPublicItemCoverView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var numLB: UILabel!
    
    var tid:String?
    
    
    func setData(_ dic:[String:Any],_ indexPath: IndexPath) {
        if indexPath.row == 0
        {
            if indexPath.section == 0
            {
                self.dayLB.text = "今天"
                self.monthLB.isHidden = true
                self.dayLB.isHidden = false
                coverview.setTodayCamera()
                self.titleLB.text = ""
                self.numLB.isHidden = true
            }else{
                self.dayLB.isHidden = false
                self.monthLB.isHidden = false
                self.dayLB.text = (dic["createTime"] as! String)[8..<9]
                let index = (dic["createTime"] as! String).index((dic["createTime"] as! String).startIndex, offsetBy: 5)
                let str = (dic["createTime"] as! String)[index]
                if str == "0" {
                   self.monthLB.text = "\((dic["createTime"] as! String)[(dic["createTime"] as! String).index((dic["createTime"] as! String).startIndex, offsetBy: 6)])月"
                }
                else {
                  self.monthLB.text = (dic["createTime"] as! String)[5..<6] + "月"
                }
                setCoverInfo(dic)
            }
            
        }else{
            self.dayLB.isHidden = true
            self.monthLB.isHidden = true
            setCoverInfo(dic)
        }
    }
    
    func setCoverInfo(_ dic:[String:Any])
    {
        self.tid = dic["tid"] as? String
        self.titleLB.text = dic["title"] as? String
        let imgs = dic["imgs"] as? [String]
        if imgs == nil || (imgs?.isEmpty)!
        {
            coverview.setVideoCover(dic["cover"] as! String)
            self.numLB.isHidden = true
            
        }else{
            self.numLB.isHidden = false
            coverview.setImages(imgs!)
            self.numLB.text = "共\(imgs!.count)张"
        }
        titleLB.text = dic["content"] as? String
    }
}
