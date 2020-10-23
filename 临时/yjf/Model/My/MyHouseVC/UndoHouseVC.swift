//
//  UndoHouseVC.swift
//  YJF
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class UndoHouseVC: BaseVC {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeHolderLB: UILabel!
    
    @IBOutlet weak var yesBtn: UIButton!
    
    @IBOutlet weak var noBtn: UIButton!
    
    private let house: [String : Any]
    
    init(_ house: [String : Any]) {
        self.house = house
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "撤销房源"
        textView.delegate = self
    }
    
    @IBAction func yesOrNoAction(_ sender: UIButton) {
        if sender.isSelected == true {return}
        guard let type = house["dzyType"] as? MyHouseType else {return}
        var canRemove = true
        switch type {
        case .waitAudit(let lockType, _, _),
             .auditSuccess(let lockType, _, _),
             .released(let lockType, _, _):
            if lockType == .noDeposit ||
                lockType == .unInstall ||
                lockType == .installing
            {
                canRemove = false
            }
        default:
            break
        }
        if !canRemove && sender == yesBtn {
            showMessage("您尚未装锁")
        }else {
            sender.isSelected = true
            (sender == yesBtn ? noBtn : yesBtn)?.isSelected = false
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        guard let msg = textView.text, msg.count > 0 else {
            showMessage("请输入撤销原因")
            return
        }
        let dic: [String : Any] = [
            "houseId" : house.intValue("id") ?? 0,
            "message" : msg,
            "lockType" : yesBtn.isSelected ? 10 : 20
        ]
        let alert = dzy_normalAlert("提示", msg: "您确定要撤销该房源么?", sureClick: { (_) in
            self.undoApi(dic)
        }, cancelClick: nil)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //    MAKR: - api
    private func undoApi(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.undoHouse
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                self.showMessage("操作成功")
                self.dzy_pop()
                NotificationCenter.default.post(
                    name: PublicConfig.Notice_UndoHouseSuccess,
                    object: nil
                )
            }
        }
    }
}

extension UndoHouseVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLB.isHidden = textView.text.count > 0
    }
}
