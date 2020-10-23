//
//  CoachSelectStudentVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import SCIndexView
import ContactsUI

fileprivate let NaContactHeaderH: CGFloat = 24.0

protocol CoachSelectStudentDelegate:NSObjectProtocol {
    func selectStudent(_ user:[String:Any])
}

class CoachSelectStudentVC: BaseVC {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableview: UITableView!
    // 原始数据

    lazy var originArr = [StudentUserModel]()
    // 呈现数据
    lazy var dataBookArr = [[StudentUserModel]]()
    // MARK: 索引数组
    lazy var sectionArr = [String]()
    
    weak var delegate:CoachSelectStudentDelegate?
    
    lazy var importContactBtn: UIButton = {
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        rightBtn.setTitle("从通讯录导入", for: .normal)
        rightBtn.setTitleColor(YellowMainColor, for: .normal)
        rightBtn.titleLabel?.font = ToolClass.CustomFont(15)
        rightBtn.addTarget(self, action: #selector(importFromAddressbook), for: .touchUpInside)
        rightBtn.sizeToFit()
        return rightBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBar()
        self.title = "学员选择"
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        self.searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.tableview.register(UINib(nibName: "AddressBookCell", bundle: nil), forCellReuseIdentifier: "AddressBookCell")
        
        let configuration = SCIndexViewConfiguration(indexViewStyle: .default)
        configuration?.indicatorBackgroundColor = YellowMainColor
        configuration?.indicatorTextColor = BackgroundColor
        configuration?.indexItemTextColor = Text1Color
        configuration?.indexItemSelectedBackgroundColor = YellowMainColor
        configuration?.indexItemSelectedTextColor = BackgroundColor
        self.tableview.sc_indexViewConfiguration = configuration
        
        getStudentListAPI()
    }
    
    func addNavigationBar()
    {
        let rightBar = UIBarButtonItem(customView: self.importContactBtn)
        self.navigationItem.rightBarButtonItem = rightBar
    }
    
    @objc func importFromAddressbook()
    {
        let cpvc = CNContactPickerViewController()
        // 2.设置代理
        cpvc.delegate = self
        // 3.弹出控制器
        cpvc.modalPresentationStyle = .fullScreen
        present(cpvc, animated: true, completion: nil)
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
            
            self.dataArr = data?["list"] as! [[String:Any]]
            for dic in self.dataArr{
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
            
            self.dataBookArr = StudentUserModel.getMemberListData(by: data)
            self.sectionArr = StudentUserModel.getFriendListSection(by: self.dataBookArr)
            
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
}

extension CoachSelectStudentVC:CNContactPickerDelegate
{
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//        let lastname = contact.familyName
//        let firstname = contact.givenName
        let name = contact.familyName + contact.givenName
        var mobile = ""
        
        // 2.获取用户电话号码(ABMultivalue)
        let phones = contact.phoneNumbers
        for phone in phones {
//            let phoneLabel = phone.label
            var phoneValue = phone.value.stringValue
            phoneValue = phoneValue.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
            if phoneValue.hasPrefix("+86")
            {
                if phoneValue.hasPrefix("+86·")
                {
                    phoneValue = phoneValue[4,phoneValue.count-4]
                }else{
                    phoneValue = phoneValue[3,phoneValue.count-3]
                }
            }else if phoneValue.hasPrefix("86")
            {
                phoneValue = phoneValue[2,phoneValue.count-2]

            }
            
            mobile = phoneValue
            break
        }
        let dic = ["name":name,"mobile":mobile]
        
        self.delegate?.selectStudent(dic)
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension CoachSelectStudentVC:UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource
{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataBookArr.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataBookArr[section].count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressBookCell", for: indexPath) as! AddressBookCell
        var data: StudentUserModel?
        data = dataBookArr[indexPath.section][indexPath.row]
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

        return NaContactHeaderH
    }
    
    // 返回每个索引的内容
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArr[section]
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        

            let userModel = self.dataBookArr[indexPath.section][indexPath.row]
            
            let user = ["nickname":userModel.name!,"uid":userModel.uid!]
            
            self.delegate?.selectStudent(user)
            
            self.navigationController?.popViewController(animated: true)
        

    }
}

