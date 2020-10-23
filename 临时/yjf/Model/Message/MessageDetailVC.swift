//
//  MessageDetailVC.swift
//  YJF
//
//  Created by edz on 2019/7/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

class MessageDetailVC: BaseVC, CzzdJumpProtocol {
    
    private let msg: [String : Any]
    
    private let type: MessageType
    
    private let twoDepositKey = "【缴纳交易保证金】"
    
    private let twoLockKey = "【申请装锁】"
    
    // skipType == 64 时是否为两条信息
    private var isTwo: Bool {
        var count = 0
        let content = msg.stringValue("content") ?? ""
        if content.contains(twoDepositKey) {
            count += 1
        }
        if content.contains(twoLockKey) {
            count += 1
        }
        return count == 2
    }
    
    private var parameList: [String : String] {
        return MessageHelper
            .openParameList(msg.stringValue("parameList") ?? "")
    }

    @IBOutlet weak var tableView: UITableView!
    
    init(_ msg: [String : Any], type: MessageType) {
        self.msg = msg
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "消息详情"
        tableView.dzy_registerCellNib(MessageListInfoCell.self)
        tableView.dzy_registerCellNib(MessageListLinkCell.self)
        tableView.dzy_registerCellNib(MessageListTwoLinkCell.self)
        saveStaffMsg()
        readApi()
    }
    
    private func saveStaffMsg() {
        var staffMsg: [String : Any] = [:]
        guard let staffCode = parameList.stringValue("staffCode") else {
            return
        }
        staffMsg["staffCode"] = staffCode
        if let remark = parameList.stringValue("remark"),
            remark.count > 0
        {
            staffMsg["remark"] = remark
        }else {
            staffMsg["remark"] = "电推"
        }
        DataManager.saveStaffMsg(staffMsg)
    }
    
    private func readApi() {
        guard let msgId = msg.intValue("id") else {return}
        let request = BaseRequest()
        request.url = BaseURL.readMessage
        request.dic = ["messageIdList" : ToolClass.toJSONString(dict: [msgId])]
        request.start { (_, _) in
            
        }
    }
    
    private func checkHouseApi(_ houseId: Int,
                               handler: @escaping (Bool)->())
    {
        let request = BaseRequest()
        request.url = BaseURL.checkHouseType
        request.dic = ["houseId" : houseId]
        ZKProgressHUD.show()
        request.start { (data, error) in
            ZKProgressHUD.dismiss()
            handler((data?.intValue("houseStatus") ?? 0) <= 10)
        }
    }
}

extension MessageDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let skipType = msg.intValue("skipType") ?? 0
        switch type {
        case .czzd where skipType == 57, // 操作指导
             .czzd where skipType == 62,
             .czzd where skipType == 64 && !isTwo,
             .xtxx where skipType == 6,  // 评价
             .xtxx where skipType == 45, // 交易进展
             .jytx where skipType == 25, // 缴纳买方保证金
             .jytx where skipType == 33, // 缴纳卖方保证金
             .jytx where skipType == 29: // 缴纳买方保证金
            return 190.0
        case .czzd where skipType == 63,
             .czzd where skipType == 64 && isTwo:
            return 235.0
        default:
            return 154.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skipType = msg.intValue("skipType") ?? 0
        switch type {
        case .czzd where skipType == 57, // 操作指导
             .czzd where skipType == 62,
             .czzd where skipType == 64 && !isTwo,
             .xtxx where skipType == 6,  // 评价
             .xtxx where skipType == 45, // 交易进展
             .jytx where skipType == 25, // 缴纳买方保证金
             .jytx where skipType == 33, // 缴纳卖方保证金
             .jytx where skipType == 29: // 缴纳买方保证金
            let cell = tableView
                .dzy_dequeueReusableCell(MessageListLinkCell.self)
            cell?.delegate = self
            cell?.updateUI(msg)
            return cell!
        case .czzd where skipType == 63,
             .czzd where skipType == 64 && isTwo:
            let cell = tableView
                .dzy_dequeueReusableCell(MessageListTwoLinkCell.self)
            cell?.delegate = self
            cell?.updateUI(msg)
            return cell!
        default:
            let cell = tableView
                .dzy_dequeueReusableCell(MessageListInfoCell.self)
            cell?.updateUI(msg)
            return cell!
        }
    }
}

extension MessageDetailVC: MessageListLinkCellDelegate {
    func messageCell(_ cell: MessageListLinkCell, didClickJumpBtn btn: UIButton)
    {
        let skipType = msg.intValue("skipType") ?? 0
        switch type {
        case .xtxx where skipType == 6:  // 评价
            if let str = msg.stringValue("parameList") {
                let task = ToolClass
                    .getDictionaryFromJSONString(jsonString: str)
                let vc = EvaluateAndFBBaseVC()
                vc.task = task
                dzy_push(vc)
            }
        case .xtxx where skipType == 45: // 交易进展
            orderProgress()
        case .jytx where [25, 29].contains(skipType): // 缴纳买方保证金
            let vc = PayBuyDepositVC(.normal)
            dzy_push(vc)
        case .jytx where skipType == 33: // 缴纳卖方保证金
            let vc = PaySellDepositVC(.normal)
            dzy_push(vc)
        case .czzd where skipType == 57 || skipType == 62:
            if let type = parameList.stringValue("urlType")
            {
                czzdAction(type)
            }
        case .czzd where skipType == 64:
            let content = msg.stringValue("content") ?? ""
            if content.contains(twoDepositKey) {
                let vc = PaySellDepositVC(.normal)
                dzy_push(vc)
            }else if content.contains(twoLockKey) {
                let vc = MyHouseVC()
                dzy_push(vc)
            }
        default:
            break
        }
    }
}

extension MessageDetailVC: MessageListTwoLinkCellDelegate {
    func twoLinkCell(_ cell: MessageListTwoLinkCell, didClickTopLinkWithBtn btn: UIButton)
    {
        let skipType = msg.intValue("skipType") ?? 0
        if skipType == 63 {
            editHouse()
        }else if skipType == 64 {
            let vc = PaySellDepositVC(.normal)
            dzy_push(vc)
        }
    }
    
    func twoLinkCell(_ cell: MessageListTwoLinkCell, didClickBottomLinkWithBtn btn: UIButton)
    {
        let skipType = msg.intValue("skipType") ?? 0
        if skipType == 63 {
            addPrice()
        }else if skipType == 64 {
            let vc = MyHouseVC()
            dzy_push(vc)
        }
        
    }
    
    private func editHouse() {
        guard let parameList = msg.stringValue("parameList") else {
            return
        }
        let dic = MessageHelper.openParameList(parameList)
        guard let houseIdStr = dic.stringValue("houseId"),
            let houseId = Int(houseIdStr)
        else {
            return
        }
        checkHouseApi(houseId) { [weak self] canEdit in
            if canEdit {
                let vc = AddHouseBaseVC(RegionManager.cityId(),
                                        type: .edit)
                vc.houseId = houseId
                self?.dzy_push(vc)
            }else {
                ToolClass.showToast("改房源已经成交，无法编辑", .Failure)
            }
        }
    }
    
    private func addPrice() {
        guard let houseId = Int(parameList.stringValue("houseId") ?? "")
        else {return}
        
        checkHouseApi(houseId) { [weak self] canEdit in
            if canEdit {
                let vc = HouseDetailVC(houseId)
                vc.firstShowIndex = 1
                self?.dzy_push(vc)
            }else {
                ToolClass.showToast("改房源已经成交，无法添加报价", .Failure)
            }
        }
    }
    
    private func orderProgress() {
        guard let houseId = Int(parameList.stringValue("houseId") ?? ""),
            let dealNo = parameList.stringValue("dealNo")
        else {
            ToolClass.showToast("数据格式错误", .Failure)
            return
        }
        let vc = OrderProgressBaseVC(houseId, dealNo: dealNo)
        dzy_push(vc)
    }
}
