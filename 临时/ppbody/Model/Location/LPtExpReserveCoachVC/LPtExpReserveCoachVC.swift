//
//  LocationReserveCoachVC.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpReserveCoachVC: BaseVC, AttPriceProtocol {
    /// 分享来源
    var fpp: String?
    /// 名字
    @IBOutlet weak var nameLB: UILabel!
    /// 信息
    @IBOutlet weak var msgLB: UILabel!
    /// 单价
    @IBOutlet weak var sPriceLB: UILabel!
    /// 个数
    @IBOutlet weak var numLB: UILabel!
    /// 团购的总价
    @IBOutlet weak var tGroupPriceLB: UILabel!
    /// 原价的总价
    @IBOutlet weak var tOriginPriceLB: UILabel!
    
    @IBOutlet weak var coachCLView: UICollectionView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private let ptExpDetail: [String : Any]
    
    private var ptList: [[String : Any]] = []
    
    private var num: Int {
        guard let numStr = numLB.text,
            let num = Int(numStr)
        else {return 1}
        return num
    }
    
    init(_ ptExpDetail: [String : Any]) {
        self.ptExpDetail = ptExpDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        stackView.isHidden = true
        ptListApi()
    }

    func initUI() {
        navigationItem.title = "私教预约确认"
        coachCLView.dzy_registerCellFromNib(LGymCoachCell.self)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 110.0, height: 200.0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        coachCLView.collectionViewLayout = layout
        
        nameLB.text = ptExpDetail.stringValue("name")
        msgLB.text = ptExpDetail.stringValue("title")
        let price = ptExpDetail.doubleValue("presentPrice") ?? 0
        sPriceLB.attributedText = attPriceStr(
            price,
            info: "/人",
            signFont: dzy_Font(18),
            priceFont: dzy_Font(10))
        updatePrice()
    }
    
    func updateUI(_ data: [String : Any]) {
        ptList = (data.arrValue("list") ?? []).map({
            var temp = $0
            temp[SelectedKey] = false
            return temp
        })
        ptList.insert([
            "name" : "随机",
            "departMent" : "随机分配教练",
            SelectedKey : true
        ], at: 0)
        timeView.initUI(ptExpDetail.stringValue("orderTime") ?? "",
                        duration: ptExpDetail.intValue("duration") ?? 0)
        stackView.addArrangedSubview(timeView)
        stackView.isHidden = false
        coachCLView.reloadData()
    }
    
//    MARK: - 支付
    @IBAction func payAction(_ sender: UIButton) {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let pt = ptList
            .first(where: {$0.boolValue(SelectedKey) == true})
        else {
            ToolClass.showToast("请选择教练", .Failure)
            return
        }
        guard let orderTime = timeView.reserveTime else {
            ToolClass.showToast("请选择预约时间", .Failure)
            return
        }
        guard let date = format.date(from: orderTime),
            date.compare(Date()) != .orderedAscending
        else {
            ToolClass.showToast("您选择的时间已过期", .Failure)
            return
        }
        guard let expId = ptExpDetail.intValue("id"),
            let sprice = ptExpDetail.doubleValue("presentPrice"),
            let name = ptExpDetail.stringValue("name")
        else {
            ToolClass.showToast("体验课数据错误", .Failure)
            return
        }
        let pid = pt.stringValue("pid")
        let pname = pt.stringValue("name")
        
        let price = sprice * Double(num)
        var dic: [String : String] = [
            "type" : "20",
            "lbsGoodId" : "\(expId)",
            "num" : "\(num)",
            "price" : "\(price)",
            "orderTime" : orderTime
        ]
        if pid != nil {
            dic["ptName"] = pname ?? ""
        }
        submitApi(dic, pid: pid) { [weak self] (orderId) in
            let vc = LocationPayVC(orderId, price: price, name: name)
            self?.dzy_push(vc)
        }
    }
    
    //    MARK: - 加、减
    @IBAction func addAction(_ sender: UIButton) {
        guard let numStr = numLB.text,
            let num = Int(numStr)
        else {return}
        numLB.text = "\(num + 1)"
        updatePrice()
    }
    
    @IBAction func reduceAction(_ sender: UIButton) {
        guard let numStr = numLB.text,
            let num = Int(numStr),
            num > 1
        else {return}
        numLB.text = "\(num - 1)"
        updatePrice()
    }
    
    private func updatePrice() {
        let gprice = ptExpDetail.doubleValue("presentPrice") ?? 0
        let oprice = ptExpDetail.doubleValue("originPrice") ?? 0
        let oTotal = oprice * Double(num)
        tGroupPriceLB.attributedText = attPriceStr(gprice * Double(num))
        tOriginPriceLB.text = "门市价￥\(oTotal.decimalStr)"
    }
    
//    MARK: - api
    private func ptListApi() {
        guard let cid = ptExpDetail.stringValue("cid") else {return}
        let request = BaseRequest()
        request.url = BaseURL.LPtList
        request.setClubId(cid)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data {
                self.updateUI(data)
            }
        }
    }
    
    //    MARK: - Api
    private func submitApi(_ dic: [String : String],
                           pid: String?,
                           complete: @escaping (Int)->()) {
        let request = BaseRequest()
        request.url = BaseURL.LSubmitOrder
        request.dic = dic
        request.isUser = true
        request.setFpp(fpp)
        pid.flatMap({
            request.setPtId($0)
        })
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            data?.intValue("lbsOrderId").flatMap({
                complete($0)
            })
        }
    }
    
//    MARK: - 懒加载
    private lazy var timeView: LPtExpRCTimeView = {
        let view = LPtExpRCTimeView.initFromNib()
        return view
    }()
    
    private lazy var userInfoView: LPtExpRCUserInfoView = {
        let view = LPtExpRCUserInfoView.initFromNib()
        view.initUI()
        return view
    }()
}

extension LPtExpReserveCoachVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return ptList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell = collectionView
            .dzy_dequeueCell(LGymCoachCell.self, indexPath)
        cell?.updateUI(ptList[indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        ptList = ptList.map({
            var temp = $0
            temp[SelectedKey] = false
            return temp
        })
        ptList[indexPath.row][SelectedKey] = true
        collectionView.reloadData()
    }
}
