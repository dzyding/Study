//
//  TribeFoundHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TribeFoundHead: UICollectionReusableView{
    
    @IBOutlet weak var stackview: UIStackView!
    
    var dataArr = [[String:Any]]()
    
    override func awakeFromNib() {

    }
    
    func setData(_ tribeArr:[[String:Any]])
    {
        self.dataArr = tribeArr
        
        for view in self.stackview.arrangedSubviews
        {
            self.stackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        let max = self.dataArr.count > 6 ? 6 : self.dataArr.count
        
        for i in 0..<max {
            let dic = self.dataArr[i]
            let tag = TribeView.instanceFromNib()
            tag.setData(dic)
            tag.tag = i
            tag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapTribeView(_:))))
            self.stackview.addArrangedSubview(tag)
        }
    }
    
    @objc func tapTribeView(_ tap: UITapGestureRecognizer)
    {
        let tag = tap.view?.tag

        let dic = self.dataArr[tag!]
        
        let fromVC = ToolClass.controller2(view: self)
        
        let vc = TribeTrendsVC.init(nibName: "TribeTrendsVC", bundle: nil)
        vc.ctid = dic["ctid"] as! String
        vc.title = dic["name"] as? String
        fromVC?.tabBarController?.navigationController?.pushViewController(vc, animated: true)
        
    }
}
