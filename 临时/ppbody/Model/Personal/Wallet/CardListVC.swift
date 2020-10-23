//
//  CardListVC.swift
//  PPBody
//
//  Created by edz on 2018/12/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CardListVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    var current: [String : Any]?
    
    weak var takeMoneyVC: TakeSweatVC?
    // 解除绑定的 ID
    fileprivate var deleteCardID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择银行卡"
        
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(CardListCell.self)
        
        let btn = UIBarButtonItem(image: UIImage(named: "cardList_add"), style: .done, target: self, action: #selector(addCardAction))
        navigationItem.rightBarButtonItem = btn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardListApi()
    }
    
    @objc func addCardAction() {
        let vc = AddCardVC()
        dzy_push(vc)
    }
    
    //    MARK: - 设置默认银行卡之后的操作
    func setDefaultCardNext(_ cardId: Int) {
        (0..<dataArr.count).forEach { (index) in
            dataArr[index].updateValue(false, forKey: "isSelected")
            dataArr[index].updateValue(10, forKey: "status")
        }
        if let index = dataArr.firstIndex(where: {$0.intValue("id") == cardId}) {
            dataArr[index].updateValue(true, forKey: "isSelected")
            dataArr[index].updateValue(20, forKey: "status")
        }
        tableView.reloadData()
    }
    
    //    MARK: - 解除银行卡之前的弹框
    func deleteAlertShow() {
        let alert = dzy_normalAlert("提示", msg: "解除绑定之后将无法返回，确认解除？", sureClick: { [weak self] (_) in
            self?.cardDeleteApi()
        }, cancelClick: nil)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //    MARK: - 解除银行卡之后的操作
    func deleteCardNext(_ cardId: Int) {
        if let index = dataArr.firstIndex(where: {$0.intValue("id") == cardId}) {
            let removeModel = dataArr.remove(at: index)
            if removeModel.boolValue("isSelected") == true { //如果解除的正好是当前选中的，需要更改前一个界面的状态
                takeMoneyVC?.data = dataArr.first ?? [:]
                takeMoneyVC?.update()
            }
        }
        tableView.reloadData()
    }
    
    //    MARK: - 银行卡列表
    func cardListApi() {
        let request = BaseRequest()
        request.url = BaseURL.CardList
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if var list = data?["list"] as? [[String : Any]] {
                (0..<list.count).forEach({ [weak self] (index) in
                    let sel = list[index].intValue("id") == self?.current?.intValue("id") ? true : false
                    list[index].updateValue(sel, forKey: "isSelected")
                })
                self?.dataArr = list
                self?.tableView.reloadData()
            }
        }
    }
    
    //    MARK: - 成为默认银行卡
    func cardBeDefaultApi(_ cardId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.CardBeDefault
        request.dic = [
            "cardId" : "\(cardId)"
        ]
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self?.setDefaultCardNext(cardId)
        }
    }
    
    //    MARK: - 解除绑定
    func cardDeleteApi() {
        guard let cardId = deleteCardID else {return}
        let request = BaseRequest()
        request.url = BaseURL.CardDelete
        request.dic = [
            "cardId" : "\(cardId)"
        ]
        request.isUser = true
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self?.deleteCardNext(cardId)
        }
    }
}

extension CardListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(CardListCell.self)
        cell?.data = dataArr[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArr[indexPath.row]
        takeMoneyVC?.data = data
        takeMoneyVC?.update()
        dzy_pop()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .normal, title: "设为默认", handler: { [weak self] (action, indexPath) in
            if let cardId = self?.dataArr[indexPath.row].intValue("id") {
                self?.cardBeDefaultApi(cardId)
            }
        })
        action1.backgroundColor = YellowMainColor
        
        let action2 = UITableViewRowAction(style: .normal, title: "解绑", handler: { [weak self] (action, indexPath) in
            if let cardId = self?.dataArr[indexPath.row].intValue("id") {
                self?.deleteCardID = cardId
                self?.deleteAlertShow()
            }
        })
        action2.backgroundColor = RGB(r: 142.0, g: 142.0, b: 142.0)
        
        return [action2, action1]
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.subviews.forEach { (v) in
            if !v.isKind(of: CardListCell.self) {
                v.subviews.forEach({ (btnView) in
                    if let btn = btnView as? UIButton,
                        btn.title(for: .normal) == "设为默认"
                    {
                        btn.setTitleColor(RGB(r: 51.0, g: 51.0, b: 51.0), for: .normal)
                    }
                })
            }
        }
    }
}
