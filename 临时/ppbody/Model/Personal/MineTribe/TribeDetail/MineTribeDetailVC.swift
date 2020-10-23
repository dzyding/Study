//
//  MineTribeDetailVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MineTribeDetailVC: BaseVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    var ctid = ""
    
    let headerView = MineTribeDetailHeaderView.instanceFromNib()
    let noticeView = MineTribeDetailNoticeView.instanceFromNib()
    let tribeListView = MineTribeListView.instanceFromNib()
    let chartView = MineTribeChartView.instanceFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "部落详情"
        scrollView.contentInset = UIEdgeInsets(top: 240.0, left: 0, bottom: 0, right: 0)
        scrollView.delegate = self
        headerView.frame = CGRect.init(x: 0, y: -240.0, width: ScreenWidth, height: 240.0)
        scrollView.addSubview(headerView)
        stackView.addArrangedSubview(noticeView)
        stackView.addArrangedSubview(tribeListView)
        stackView.addArrangedSubview(chartView)
        
        self.loadApi()
        
    }
    
    
    func loadApi() {
        let request = BaseRequest()
        request.url = BaseURL.TribeDetail
        request.dic = ["ctid": ctid]
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let tribe = data?["tribe"] as! Dictionary<String,Any>
            self.dataDic = tribe
            self.setData(data: tribe)
        }
    }
    
    func setData(data: [String:Any]) {
        
        
        let isEdit = data["isEdit"] as? Int
        if isEdit != nil && isEdit == 1
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "mind_nav_icon_edit"), style: .plain, target: self, action: #selector(rightItemClick))
        }

        
        headerView.setData(data)
        
        noticeView.setData(data)

        tribeListView.setData(data)
        
        let rankList = data["rank"] as! [[String:Any]]
        chartView.setData(rankList)
        
    }
    
    @objc func rightItemClick() {
        
        let vc = MineTribeDetailEditVC.init(nibName: "MineTribeDetailEditVC", bundle: nil)
        vc.dataDic = self.dataDic
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}

extension MineTribeDetailVC : UIScrollViewDelegate,MineTribeDetailEditVCDelegate {
    
    func editTribeSuccess(_ data: [String : Any]) {
    
        let name = data["name"] as? String
        
        if name != nil
        {
            headerView.lblTitle.text = name
        }
        
        let slogan = data["slogan"] as? String
        
        if slogan != nil
        {
            headerView.lblDesc.text = slogan
        }
        
        let notice = data["notice"] as? String
        
        if notice != nil
        {
            noticeView.lblContent.attributedText = ToolClass.rowSpaceText(notice!, system: 14)
        }
        
        let city = data["city"] as? String
        
        if city != nil
        {
            headerView.lblArea.text = city
        }
        
        let cover = data["cover"] as? String
        
        if cover != nil
        {
            headerView.imgBg.setCoverImageUrl(cover!)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y < -240.0 {
            headerView.frame = CGRect.init(x: 0, y: y, width: headerView.frame.size.width, height: -y)
        }
        
    }
}















