//
//  MyVC.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum MyFuncType {
    ///竞买
    case bid
    ///实地看过的房源
    case looked
    ///佣金折扣
    case discount
    ///收藏
    case collect
    ///关注
    case attention
    ///浏览过的
    case footmark
    ///评价
    case evaluate
    ///我的房源
    case myHouse
    ///优显
    case showFirst
    ///客服
    case about
}

class MyVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var nickNameLB: UILabel!
    
    // 两个保证金相关的按钮和lb
    @IBOutlet weak var addDepositBtn: UIButton!
    
    @IBOutlet weak var topDepositLB: UILabel!
    
    @IBOutlet weak var topBtn: UIButton!
    
    @IBOutlet weak var bottomDepositLB: UILabel!
    
    @IBOutlet weak var bottomBtn: UIButton!
    
    @IBOutlet weak var versionLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topViewHeightLC.constant = IS_IPHONEX ? 197.0 : 175.0
        tableView.backgroundColor = dzy_HexColor(0xf5f5f5)
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(MyFuncCell.self)
        versionLB.text = Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 刷新买方，卖方
        tableView.reloadData()
        PublicFunc.updateUserDetail { (user, tradeInfo, _) in
            self.updateUI(user, tradeInfo: tradeInfo)
        }
    }
    
    private func updateUI(_ user: [String : Any]?, tradeInfo: [String : Any]?) {
        nickNameLB.text = user?.stringValue("nickname")
        
        let buyDeposit  = tradeInfo?.doubleValue("buyCashDeposit") ?? 0
        let buyLook     = tradeInfo?.doubleValue("buyLookPrice") ?? 0
        let buy = buyDeposit + buyLook
        
        let sellDeposit = tradeInfo?.doubleValue("sellCashDeposit") ?? 0
        let sellLock    = tradeInfo?.doubleValue("sellLookPrice") ?? 0
        let sell = sellDeposit + sellLock
        
        func baseFunc(_ topDeposit: Double, bottomDeposit: Double) {
            if topDeposit > 0 {
                topBtn.isHidden = false
                addDepositBtn.isHidden = true
                if let text = topDepositLB.text {
                    topDepositLB.text = text + topDeposit.decimalStr + " >"
                }
            }else {
                topBtn.isHidden = true
                addDepositBtn.isHidden = false
            }
            if bottomDeposit > 0 {
                bottomDepositLB.isHidden = false
                if let text = bottomDepositLB.text {
                    bottomDepositLB.text = text + bottomDeposit.decimalStr
                }
            }else {
                bottomDepositLB.isHidden = true
            }
        }
        // 第二行任何情况下都不让点击
        bottomBtn.isHidden = true
        switch IDENTITY {
        case .buyer:
            topDepositLB.text = "买方保证金："
            bottomDepositLB.text = "卖方保证金："
            baseFunc(buy, bottomDeposit: sell)
        case .seller:
            topDepositLB.text = "卖方保证金："
            bottomDepositLB.text = "买方保证金："
            baseFunc(sell, bottomDeposit: buy)
        }
    }
    
    //    MARK: - 缴纳保证金
    @IBAction func payDepositAction(_ sender: UIButton) {
        switch IDENTITY {
        case .buyer:
            let vc = DepositVC(.buyer)
            dzy_push(vc)
        case .seller:
            let vc = DepositVC(.seller)
            dzy_push(vc)
        }
    }
    
    //    MARK: - 买/卖 保证金
    @IBAction func topDepositAction(_ sender: UIButton) {
        switch IDENTITY {
        case .buyer:
            let vc = DepositVC(.buyer)
            dzy_push(vc)
        case .seller:
            let vc = DepositVC(.seller)
            dzy_push(vc)
        }
    }
    
    @IBAction func bottomDepositAction(_ sender: UIButton) {
        switch IDENTITY {
        case .buyer:
            let vc = DepositVC(.seller)
            dzy_push(vc)
        case .seller:
            let vc = DepositVC(.buyer)
            dzy_push(vc)
        }
    }
    
    //    MARK: - 用户信息
    @IBAction func infoAction(_ sender: UIButton) {
        let vc = MyInfoVC()
        dzy_push(vc)
    }
    
    //    MARK: - 我的二维码
    @IBAction func shareAction(_ sender: UIButton) {
        let vc = ShareVC()
        dzy_push(vc)
    }
    
    //    MARK: api
    
    //    MARK: - 懒加载
    private var datas:[[MyFuncType]] {
        var temp:[MyFuncType] = IDENTITY == .buyer ? [.bid, .looked] : [.myHouse, .showFirst]
        temp += [.attention, .collect, .footmark]
        return [
            temp,
            [.discount, .evaluate],
            [.about]
        ]
    }
}

extension MyVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = datas[indexPath.section]
        let cell = tableView.dzy_dequeueReusableCell(MyFuncCell.self)
        cell?.updateUI(sectionData[indexPath.row])
        cell?.lineView.isHidden = (sectionData.count - 1) == indexPath.row
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 10.0))
        view.backgroundColor = dzy_HexColor(0xf5f5f5)
        return view
    }
    
    //swiftlint:disable:next superfluous_disable_command
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = datas[indexPath.section][indexPath.row]
        switch type {
        case .evaluate:
            let vc = EvaluateAndFBBaseVC()
            dzy_push(vc)
        case .collect:
            let vc = CollectAndAttentionVC(.collect)
            dzy_push(vc)
        case .attention:
            let vc = CollectAndAttentionVC(.attention)
            dzy_push(vc)
        case .looked:
            let vc = LookedVC()
            dzy_push(vc)
        case .footmark:
            let vc = FootMarkVC()
            dzy_push(vc)
        case .bid:
            let vc = MyBidBaseVC()
            dzy_push(vc)
        case .discount:
            let vc = DiscountVC()
            dzy_push(vc)
        case .myHouse:
            let vc = MyHouseVC()
            dzy_push(vc)
        case .showFirst:
            let vc = ShowFirstVC()
            dzy_push(vc)
        case .about:
            let vc = AboutUsVC()
            dzy_push(vc)
        }
    }
}
