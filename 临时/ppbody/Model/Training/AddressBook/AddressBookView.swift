//
//  AddressBookView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import SCIndexView

fileprivate let NaContactHeaderH: CGFloat = 24.0

class AddressBookView: UIView {
    
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    
    // 原始数据
    lazy var originArr = [StudentUserModel]()
    // 呈现数据
    lazy var dataArr = [[StudentUserModel]]()
    // MARK: 索引数组
    lazy var sectionArr = [String]()
    
    var ownModel = StudentUserModel(name: "自己",head: DataManager.getHead())
    
    var selectIndexPath: IndexPath? //选中的用户切换
    
    class func instanceFromNib() -> AddressBookView {
        return UINib(nibName: "AddressBookView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AddressBookView
    }
    
    override func didMoveToSuperview() {
        openAction()
    }
    
    override func awakeFromNib() {
        
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        self.searchTF.delegate = self
        self.searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.shadeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAction)))
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.register(UINib(nibName: "AddressBookCell", bundle: nil), forCellReuseIdentifier: "AddressBookCell")
        
        let configuration = SCIndexViewConfiguration(indexViewStyle: .default)
        configuration?.indicatorBackgroundColor = YellowMainColor
        configuration?.indicatorTextColor = BackgroundColor
        configuration?.indexItemTextColor = Text1Color
        configuration?.indexItemSelectedBackgroundColor = YellowMainColor
        configuration?.indexItemSelectedTextColor = BackgroundColor
        self.tableview.sc_indexViewConfiguration = configuration
        
        getStudentListAPI()
        
        self.headIV.setHeadImageUrl(ownModel.head!)

    }
    
    @objc func closeAction()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.rightMargin.constant = self.widthConstraint.constant
            self.shadeView.alpha = 0
            self.layoutIfNeeded()
        }) { (finish) in
            if finish
            {
                self.removeFromSuperview()
            }
        }
    }
    
     func openAction()
    {
  
        UIView.animate(withDuration: 0.25, animations: {
            self.rightMargin.constant = 0
            self.shadeView.alpha = 0.5
            self.layoutIfNeeded()
        }) { (finish) in
            if finish
            {
            }
        }
    }
    
    //搜索数据
    func search(by key: String)
    {
        if key.count != 0
        {
            var searchData = [StudentUserModel]()
            for model in self.originArr
            {
                if (model.name?.contains(key))!
                {
                    searchData.append(model)
                }
            }
            resetData(searchData)
        }else{
            resetData(self.originArr)
        }
        
    }
    
    //重置数据
    func resetData(_ data: [StudentUserModel])
    {
        DispatchQueue.global(qos: .userInitiated).async {

            self.dataArr = StudentUserModel.getMemberListData(by: data)
            self.sectionArr = StudentUserModel.getFriendListSection(by: self.dataArr)
            
            DispatchQueue.main.async(execute: { [weak self] () -> Void in
                self?.tableview.reloadData()
                //清0操作 第三库的bug
                self?.tableview.sc_indexViewDataSource = [String]()
                self?.tableview.sc_indexViewDataSource = self?.sectionArr
            })
            
        }
    }
    
    
    @objc func textFieldDidChange(_ textfield : UITextField)
    {
        search(by: textfield.text!)
    }
    
    
    func getStudentListAPI()
    {
        let request = BaseRequest()
        request.url = BaseURL.CoachMemberList
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let listData = data?["list"] as! [[String:Any]]
            for dic in listData{
                let weight = (dic["weight"] as! NSNumber).floatValue.removeDecimalPoint
                
                var bodyData = "体重:" + weight + "kg"
                
                let musclePer = dic["musclePer"] as? String
                if musclePer != nil
                {
                    bodyData  = bodyData + "  肌肉比:" + musclePer!
                }
                
                let fatPer = dic["fatPer"] as? String
                if fatPer != nil
                {
                    bodyData  = bodyData + "  脂肪比:" + fatPer!
                }
                
                let remark = dic["remark"] as? String
                
                let model = StudentUserModel(name: dic["nickname"] as? String, head: dic["head"] as? String, uid: dic["uid"] as? String, sex: dic["sex"] as? Int, type: dic["type"] as? Int, remark: remark, body: bodyData)
                self.originArr.append(model)
            }
            self.resetData(self.originArr)
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
   
}

extension AddressBookView: UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource
{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArr.count+1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dataArr[section - 1].count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressBookCell", for: indexPath) as! AddressBookCell
        var data: StudentUserModel?
        if indexPath.section == 0 {
            data = ownModel
        } else {
            data = dataArr[indexPath.section - 1][indexPath.row]
        }
        cell.setData(data!)
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.na_width, height: NaContactHeaderH))
        header.backgroundColor = CardColor
        
        let titleL = UILabel(frame: header.bounds)
        titleL.text = self.tableView(tableView, titleForHeaderInSection: section)
        titleL.textColor = .white
        titleL.font = ToolClass.CustomFont(14)
        titleL.na_left = 16
        header.addSubview(titleL)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return NaContactHeaderH
    }
    
    // 返回每个索引的内容
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        return sectionArr[section - 1]
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectIndexPath == indexPath {
            return
        }
        selectIndexPath = indexPath
        if indexPath.section == 0 {
            self.headIV.setHeadImageUrl(ownModel.head!)
            DataManager.removeMemberInfo()
        }else{
            let user = self.dataArr[indexPath.section-1][indexPath.row]
            self.headIV.setHeadImageUrl(user.head!)
            DataManager.saveMemberInfo(user.getUserDic())
        }
        
        NotificationCenter.default.post(name: Config.Notify_ChangeMember, object: nil)
        
        closeAction()
    }
}
