//
//  DealVC.swift
//  YJF
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class DealVC: BaseVC {
    
    /// 左边用来显示 “总价：” 或者 “买方” 名字
    @IBOutlet weak var leftLB: UILabel!
    /// 右边用来显示 “总价：”
    @IBOutlet weak var rightLB: UILabel!
    /// 房源信息
    private let house: [String : Any]
    /// 成交信息
    private let data: [String : Any]
    /// 是否确认过购买资格
    private let isBook: Bool
    ///¥200.00万
    @IBOutlet weak var totalPriceLB: UILabel!
    ///现金 100.00万  贷款 100.00万
    @IBOutlet weak var detailPriceLB: UILabel!
    
    init(_ house: [String : Any], data: [String : Any], isBook: Bool) {
        self.house = house
        self.data = data
        self.isBook = isBook
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "成交"
        setUI()
        setInfoView()
    }
    
    deinit {
        dzy_log("销毁")
        DataManager.saveDealMsg(nil)
    }
    
    private func setUI() {
        switch IDENTITY {
        case .buyer:
            rightLB.isHidden = true
        case .seller:
            leftLB.text = data.stringValue("name")
            rightLB.isHidden = false
        }
        totalPriceLB.text = "¥\(data.doubleValue("total"), optStyle: .price)万"
        detailPriceLB.text = "现金 \(data.doubleValue("cash"), optStyle: .price)万  贷款 \(data.doubleValue("loan"), optStyle: .price)万"
    }
    
    private func setInfoView() {
        view.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(view.dzyLayout.snp.top)
            make.height.equalTo(173.0)
        }
    }
    
    @IBAction func dealAction(_ sender: UIButton) {
        guard let houseId = house.intValue("id"),
            let totalId = data.intValue("id")
        else {return}
        let dic = [
            "houseId" : houseId,
            "totalId" : totalId,
            "type" : IDENTITY == .buyer ? 10 : 20
        ]
        DataManager.saveDealMsg(dic)
        
        if IDENTITY == .buyer,
            !isBook
        {
            let handler: ([String : Any]?) -> () = { [weak self] data in
                ZKProgressHUD.dismiss()
                let restrictBuy = data?
                    .dicValue("cityConfig")?
                    .stringValue("restrictBuy") ?? "N"
                if restrictBuy == "Y",
                    self?.house.stringValue("purpose") == "住宅"
                {
                    let vc = DealAffirmVC(houseId)
                    self?.dzy_push(vc)
                }else {
                    self?.noAffirmFun()
                }
            }
            ZKProgressHUD.show()
            PublicConfig.updateCityConfig(handler)
        }else {
            noAffirmFun()
        }
    }
    
    // 不需要验证时的跳转
    private func noAffirmFun() {
        if DataManager.isPwd() == true {
            let vc = CertificationVC()
            dzy_push(vc)
        }else {
            let vc = EditMyInfoVC(.notice)
            dzy_push(vc)
        }
    }
    
    //    MARK: - 懒加载
    lazy var infoView: HouseInfoView = {
        let view = HouseInfoView.initFromNib(HouseInfoView.self)
        view.updateUI(house)
        return view
    }()

}
