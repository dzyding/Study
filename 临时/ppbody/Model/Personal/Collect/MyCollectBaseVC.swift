//
//  MyCollectBaseVC.swift
//  PPBody
//
//  Created by edz on 2019/11/2.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class MyCollectBaseVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    private let type: CollectType
    
    private let itemInfo: IndicatorInfo
    
    @IBOutlet weak var tableView: UITableView!
    
    init(_ type: CollectType) {
        self.itemInfo = IndicatorInfo(title: type.title())
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listAddHeader()
        tableView.dzy_registerCellNib(MyCollectCell.self)
        listApi(1)
    }
    
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = type == .gym ? BaseURL.CollectClubList : BaseURL.CollectClubGoodList
        request.page = [page, 20]
        request.isUser = true
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
    
    private func collectClubGoodApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.CollectClubGood
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.listApi(1)
            }
        }
    }
    
    private func collectClubApi(_ cid: String) {
        let request = BaseRequest()
        request.url = BaseURL.CollectClub
        request.dic = ["type" : "20"]
        request.setClubId(cid)
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.listApi(1)
            }
        }
    }
}

extension MyCollectBaseVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(MyCollectCell.self)
        cell?.updateUI(dataArr[indexPath.row], type: type)
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .good:
            let data = dataArr[indexPath.row]
            guard let lbsGoodId = data.intValue("lbsGoodId"),
                let goodType = data.intValue("type")
            else {
                ToolClass.showToast("商品数据错误", .Failure)
                return
            }
            if goodType == 10 { // 团购
                let vc = LocationGBDetailVC(lbsGoodId)
                dzy_push(vc)
            }else if goodType == 20 { // 体验课
                let vc = LocationPtExpDetailVC(lbsGoodId)
                dzy_push(vc)
            }
        case .gym:
            guard let cid = dataArr[indexPath.row].stringValue("cid") else {
                ToolClass.showToast("健身房数据错误", .Failure)
                return
            }
            let vc = LocationGymVC(cid)
            dzy_push(vc)
        }
    }
}

extension MyCollectBaseVC: MyCollectCellDelegate {
    func collectCell(_ cell: MyCollectCell,
                     didClickCollectBtnWith data: [String : Any])
    {
        switch type {
        case .good:
            guard let goodId = data.intValue("lbsGoodId"),
                let type = data.intValue("type")
            else {
                ToolClass.showToast("商品数据有误", .Failure)
                break
            }
            let dic: [String : String] = [
                "lbsGoodId" : "\(goodId)",
                "lbsGoodType" : "\(type)",
                "type" : "20"
            ]
            collectClubGoodApi(dic)
        case .gym:
            guard let cid = data.stringValue("cid") else {
                ToolClass.showToast("健身房数据错误", .Failure)
                return
            }
            collectClubApi(cid)
        }
    }
}

extension MyCollectBaseVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
