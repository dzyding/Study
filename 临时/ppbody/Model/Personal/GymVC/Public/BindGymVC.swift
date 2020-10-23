//
//  BindGymVC.swift
//  PPBody
//
//  Created by edz on 2019/4/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class BindGymVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var typeLB: UILabel!
    
    private var clubs: [[String : Any]]
    
    init(_ clubs: [[String : Any]]) {
        self.clubs = clubs
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelecteType()
        tableView.separatorStyle = .none
        tableView.rowHeight = 95.0
        tableView.dzy_registerCellNib(BindGymCell.self)
        
        let typeStr = DataManager.userInfo()?.intValue("type") == 10 ? "会员" : "教练"
        typeLB.text = "当前身份：" + typeStr
    }
    
    func setSelecteType() {
        (0..<clubs.count).forEach({
            clubs[$0].updateValue(false, forKey: SelectedKey)
        })
    }

    @IBAction func removeAction(_ sender: Any) {
        clubActionApi(20)
    }
    
    @IBAction func bindAction(_ sender: Any) {
        clubActionApi(10)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //    MARK: - 绑定和移除之后的操作
    func nextAction(_ club: [String : Any], action: Int) {
        if action == 10 {
            // 绑定
            dismiss(animated: true, completion: nil)
        }else {
            // 移除
            guard let id = club.intValue("id") else {return}
            clubs.removeAll(where: {$0.intValue("id") == id})
            if clubs.count > 0 {
                tableView.reloadData()
            }else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //    MARK: - 绑定 移除
    func clubActionApi(_ action: Int) {
        guard let club = clubs.filter({$0.boolValue(SelectedKey) == true}).first,
            let type = DataManager.userInfo()?.intValue("type"),
            let clubId = club.intValue("id"),
            let smid = club.intValue("smid")
        else {
            ToolClass.showToast("请选择执行操作的健身房", .Failure)
            return
        }
        let user = DataManager.userInfo()
        let dic: [String : String] =  [
            "type"      : "\(type)",
            "clubId"    : "\(clubId)",
            "smId"      : "\(smid)",
            "action"    : "\(action)",
            "head"      : user?.stringValue("head") ?? "",
            "nickname"  : user?.stringValue("nickname") ?? ""
        ]
        let request = BaseRequest()
        request.url = BaseURL.ClubAction
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.nextAction(club, action: action)
            }
        }
    }
}

extension BindGymVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(BindGymCell.self)
        cell?.updateViews(clubs[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selected = clubs[indexPath.row].boolValue(SelectedKey) {
            (0..<clubs.count).forEach({clubs[$0][SelectedKey] = false})
            clubs[indexPath.row][SelectedKey] = !selected
            tableView.reloadData()
        }
    }
}
