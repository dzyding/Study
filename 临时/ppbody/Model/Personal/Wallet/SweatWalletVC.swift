//
//  WalletVC.swift
//  PPBody
//
//  Created by edz on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SweatWalletVC: BaseVC {
    /// 充值
    @IBOutlet weak var addMoneyBtn: UIButton!
    
    @IBOutlet weak var redMoneyIV: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    /// 当前汗水值
    @IBOutlet weak var sweatLB: UILabel!
    
    @IBOutlet weak var noGiftIV: UIView!
    
    lazy var header: SWalletHeaderView = {
        let v = SWalletHeaderView.initFromNib()
        v.emptyHandler = { [weak self] empty in
            self?.noGiftOperation(empty)
        }
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的汗水"
        redMoneyIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redMoneyAction)))
        
        let btn = UIButton(type: .custom)
        btn.setTitle("历史明细", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = ToolClass.CustomFont(14)
        btn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        let detailBtn = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = detailBtn
        
        tableView.dzy_registerCellNib(SWalletReceiveGiftCell.self)
        tableView.separatorStyle = .none
        tableView.isHidden = true
        noGiftIV.isHidden = true
        
        listAddHeader(false)
        listApi(1)
        // 刷新汗水值
        getUserSweatApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sweatLB.text = "\(DataManager.getSweat()) 滴汗水"
    }
    
    //    MARK: - 跳转提现
    @IBAction func takeMoneyAction(_ sender: Any) {
        let vc = TakeSweatVC()
        dzy_push(vc)
    }
    
    //    MARK: - 跳转详情
    @objc func detailAction() {
        let vc = WalletDetailVC(.sweat)
        dzy_push(vc)
    }
    
    //    MARK: - 跳转充值
    @IBAction func addMoneyAction(_ sender: Any) {
        let vc = AddSweatVC()
        dzy_push(vc)
    }
    
    //    MARK: - 礼物流水
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.GiftFlow
        request.page = [page, 20]
        request.isUser = true
        request.start { [weak self] (data, error) in
            self?.pageOperation(data: data, error: error)
        }
    }
    
    // MARK: - 查看是否绑定微信
    @objc func redMoneyAction()
    {
        let request = BaseRequest()
        request.url = BaseURL.IfWechat
        request.isUser = true
        request.start { [weak self] (data, error) in
            if let wechat = data?.intValue("wechat") {
                if wechat == 0
                {
                    //未绑定微信
                    
                    let alert =  UIAlertController.init(title: "温馨提示", message: "您还没有绑定微信，无法操作，是否去绑定微信？", preferredStyle: .alert)
                    let actionY = UIAlertAction.init(title: "去绑定", style: .destructive) { (_) in
                        
                        ShareSDK.authorize(SSDKPlatformType.typeWechat, settings: nil, onStateChanged: { (state : SSDKResponseState, user : SSDKUser?, error : Error?) -> Void in
                            
                            switch state{
                                
                            case SSDKResponseState.success:
                                let dataInfo = user?.rawData as! [String:Any]
                                var data = [String:String]()
                                data["unionid"] = dataInfo["unionid"] as? String
                                data["openId"] = dataInfo["openid"] as? String
                                self?.bandWechat(data)
                                
                            case SSDKResponseState.fail:    print("授权失败,错误描述:\(String(describing: error))")
                            case SSDKResponseState.cancel:  print("操作取消")
                                
                            default:
                                break
                            }
                        })
                        
                    }
                    let actionN = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
                        
                    }
                    alert.addAction(actionY)
                    alert.addAction(actionN)
                    self?.present(alert, animated: true, completion: nil)
                }else{
                    let vc = LongImageVC("sweat_step")
                    vc.navigationItem.title = "领取教程"
                    self?.dzy_push(vc)
                }
            }
        }
    }
    
    //    MARK: - 获取汗水值
    func getUserSweatApi() {
        let request = BaseRequest()
        request.url = BaseURL.UserSweat
        request.isUser = true
        request.start { [weak self] (data, error) in
            if let sweat = data?.intValue("sweat") {
                DataManager.changeSweat(sweat)
                self?.sweatLB.text = "\(sweat) 滴汗水"
            }
        }
    }
    
    
    func bandWechat(_ dic:[String:String])
    {
        let request = BaseRequest()
        request.url = BaseURL.BandWechat
        request.dic = dic
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            let alert =  UIAlertController.init(title: "绑定成功", message: "微信搜索关注\"PPbody\"公众号领取红包", preferredStyle: .alert)
            
            let actionN = UIAlertAction.init(title: "ok", style: .cancel) { (_) in
                
            }
            alert.addAction(actionN)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    //    MARK: - 没有礼物时的处理
    func noGiftOperation(_ ifEmpty: Bool) {
        tableView.isHidden = ifEmpty
        noGiftIV.isHidden = !ifEmpty
    }
}

extension SweatWalletVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(SWalletReceiveGiftCell.self)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SWalletReceiveGiftCell {
            cell.data = dataArr[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
}

extension SweatWalletVC: BaseRequestProtocol {
    var re_listView: UIScrollView {
        return tableView
    }
}
