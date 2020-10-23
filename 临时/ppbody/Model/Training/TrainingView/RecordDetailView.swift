//
//  RecordDetailView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RecordDetailView: UIView {
    @IBOutlet weak var bgView: UIVisualEffectView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableviewCenterY: NSLayoutConstraint!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var dateLB: UILabel!
    
    var selectDate:Date?
    var shareItems:[[String:String]] = [["icon":"share_wechat_icon","title":"微信好友"],["icon":"share_wechat_circle_icon","title":"朋友圈"],["icon":"share_qq_space_icon","title":"QQ空间"],["icon":"share_qq_icon","title":"QQ好友"],["icon":"share_weibo_icon","title":"微博"]]
    
    var dataArr = [[String:Any]](){
        didSet{
            self.tableview.reloadData()
        }
    }
    
    class func instanceFromNib() -> RecordDetailView {
        return UINib(nibName: "TrainingView", bundle: nil).instantiate(withOwner: nil, options: nil)[4] as! RecordDetailView
    }
    
    func showDetailView()
    {
        UIView.animate(withDuration: 0.25) {
            self.bgView.alpha = 1
            self.tableviewCenterY.constant = -40
            self.layoutIfNeeded()
        }
        self.dateLB.text = "\(self.selectDate?.month ?? 0)月" + "\(self.selectDate?.day ?? 0)日"
    }
    
    
    override func awakeFromNib() {
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.register(UINib.init(nibName: "RecordDetailCell", bundle: nil), forCellReuseIdentifier: "RecordDetailCell")
        
        self.bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        
        for index in 0..<shareItems.count
        {
            let dic = shareItems[index]
            let shareItemView = ShareItemView.instanceFromNib()
            shareItemView.setData(dic)
            shareItemView.tag = index + 10
            shareItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapShareIcon(_:))))
            self.stackview.addArrangedSubview(shareItemView)
        }
    }
    
    @objc func tapShareIcon(_ tap: UITapGestureRecognizer)
    {
        let tag = tap.view?.tag
        
        switch tag {
        case 10:
            shareInfo(SSDKPlatformType.subTypeWechatSession)
            break
        case 11:
            shareInfo(SSDKPlatformType.subTypeWechatTimeline)
            break
        case 12:
            shareInfo(SSDKPlatformType.subTypeQZone)
            break
        case 13:
            shareInfo(SSDKPlatformType.subTypeQQFriend)
            break
        case 14:
            shareInfo(SSDKPlatformType.typeSinaWeibo)
            break
            
        default:
            break
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss()
    }
    
    func shareInfo(_ type:SSDKPlatformType)
    {
        let userInfo = DataManager.userInfo()
        let nickName = userInfo!["nickname"] as! String
        
        let title = nickName + "的" + self.dateLB.text! + "的健身动态"
        let cover = "https://oss.ppbody.com/logo.png"
        let content = "每一滴汗水都值得被记录"
        let shareParams = NSMutableDictionary()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: self.selectDate!)
        
        let userId = ToolClass.decryptUserId(DataManager.userAuth())
        let needCrypt = "\(userId!)" + "|" + ToolClass.randomString(length: 6) + "|" + todayStr
        
        shareParams.ssdkSetupShareParams(byText: content, images: cover, url: URL(string: Config.Share_Training_Data + "?training=" + ToolClass.encryptStr(needCrypt)!), title: title, type: SSDKContentType.webPage)
        
        ShareSDK.share(type, parameters: shareParams) { (state, info, enity, error) in
            if state == .success
            {
                
            }
        }
        
     
        let request = BaseRequest()
        request.dic = ["type":"20" , "record": todayStr]
        request.url = BaseURL.ShareSuccess
        request.isUser = true
        request.start { (data, error) in
            
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            
            
        }
    }
    
    @objc func dismiss()
    {
        self.removeFromSuperview()
    }
}

extension RecordDetailView: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordDetailCell", for: indexPath) as! RecordDetailCell
        cell.setData(data: dataArr[indexPath.row])
        cell.contentView.backgroundColor = CardColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = self.dataArr[indexPath.row]
        let motion =  dic["motion"] as! [String: Any]
        
        let code = motion["code"] as! String
        
        
        let fromVC = ToolClass.controller2(view: self) as? UINavigationController
        if code.contains("MG10006"){
            //有氧
            let vc = StatisticsCardioMotionDetailVC()
            vc.motionCode = motion["code"] as! String
            vc.title = motion["name"] as? String
            fromVC?.pushViewController(vc, animated: true)
            dismiss()
            return
        }
        
        let vc = StatisticsMotionDetailVC()
        vc.motionCode = motion["code"] as! String
        vc.title = motion["name"] as? String
        fromVC?.pushViewController(vc, animated: true)
        dismiss()
    }
    
}

