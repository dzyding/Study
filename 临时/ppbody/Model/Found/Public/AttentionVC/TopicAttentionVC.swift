//
//  TopicAttentionVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import SCIndexView

fileprivate let NaContactHeaderH: CGFloat = 24.0

protocol TopicAttentionSelectDelegate:NSObjectProtocol {
    func selectRemindUser(_ userList:[StudentUserModel])
}

class TopicAttentionVC: BaseVC {
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var scrollviewWidth: NSLayoutConstraint!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableview: UITableView!
    // 原始数据
    lazy var originModelArr = [StudentUserModel]()
    // 呈现数据
    lazy var dataModelArr = [[StudentUserModel]]()
    // MARK: 索引数组
    lazy var sectionArr = [String]()
    
    var selectUserList = [StudentUserModel]()
    
    var originUserList = [StudentUserModel]()
    
    var rightBtn:UIButton?
    
    weak var delegate:TopicAttentionSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "@谁"
        addNavigationbar()
        
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "搜索",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        self.searchTF.delegate = self
        self.searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        
        self.tableview.register(UINib(nibName: "TopicAttentionCell", bundle: nil), forCellReuseIdentifier: "TopicAttentionCell")
        
        let configuration = SCIndexViewConfiguration(indexViewStyle: .default)
        configuration?.indicatorBackgroundColor = YellowMainColor
        configuration?.indicatorTextColor = BackgroundColor
        configuration?.indexItemTextColor = Text1Color
        configuration?.indexItemSelectedBackgroundColor = YellowMainColor
        configuration?.indexItemSelectedTextColor = BackgroundColor
        self.tableview.sc_indexViewConfiguration = configuration
        
        getAttentionListAPI()
        
    }
    
    func addNavigationbar()
    {
        rightBtn = UIButton(type: .custom)
        rightBtn?.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        rightBtn?.setTitle("完成", for: .normal)
        rightBtn?.setTitleColor(YellowMainColor, for: .normal)
        rightBtn?.titleLabel?.font = ToolClass.CustomFont(15)
        rightBtn?.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        rightBtn?.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn!)
    }
    
    @objc func doneAction(_ sender: UIButton)
    {
        self.delegate?.selectRemindUser(self.selectUserList)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //搜索数据
    func search(by key: String)
    {
        if key.count != 0
        {
            var searchData = [StudentUserModel]()
            for model in self.originModelArr
            {
                if (model.name?.contains(key))!
                {
                    searchData.append(model)
                }
            }
            resetData(searchData)
        }else{
            resetData(self.originModelArr)
        }
        
    }
    
    //重置数据
    func resetData(_ data: [StudentUserModel])
    {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            
            self.dataModelArr = StudentUserModel.getMemberListData(by: data)
            self.sectionArr = StudentUserModel.getFriendListSection(by: self.dataModelArr)
            
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
    
    func getAttentionListAPI()
    {
        let request = BaseRequest()
        request.url = BaseURL.AttentionList
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

                let remark = dic["remark"] as? String
                
                let model = StudentUserModel(name: dic["nickname"] as? String, head: dic["head"] as? String, uid: dic["uid"] as? String, sex: dic["sex"] as? Int, type: dic["type"] as? Int, remark: remark)
                
                self.originModelArr.append(model)
            }
            
            for model in self.originModelArr
            {
                let uid = model.uid
                let newUserId = ToolClass.decryptUserId(uid!)
                if newUserId != nil
                {
                    for originModel in self.originUserList
                    {
                        let originUserId = ToolClass.decryptUserId(originModel.uid!)
                        if originUserId == newUserId
                        {
                            self.selectUserList.append(model)
                            self.addUserToScroll(model)
                            break
                        }
                    }
                }
            }
            
            self.resetData(self.originModelArr)
        }
    }
    
    func addUserToScroll(_ user: StudentUserModel)
    {
        
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 15
        iv.setHeadImageUrl(user.head!)
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeUserToScroll(_:))))
        self.stackview.addArrangedSubview(iv)
        
        iv.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
        }
        
        if self.selectUserList.count == 0
        {
            self.rightBtn?.setTitle("完成", for: .normal)
        }else{
            self.rightBtn?.setTitle("完成(\(self.selectUserList.count)/10)", for: .normal)
        }
        rightBtn?.sizeToFit()
        
        self.scrollviewWidth.constant = CGFloat((self.stackview.arrangedSubviews.count > 6 ? 6 : self.stackview.arrangedSubviews.count) * 40)
        self.scrollview.layoutIfNeeded()
        
        self.scrollview.setContentOffset(CGPoint(x: self.scrollview.contentSize.width - self.scrollview.na_width, y: 0), animated: true)
    }
    
    @objc func removeUserToScroll(_ tap: UITapGestureRecognizer) {
        let index = stackview.subviews.firstIndex(of: tap.view!)
        removeView(index!)
    }
    
    func removeView(_ index: Int)
    {
        let view = self.stackview.subviews[index]


        self.stackview.removeArrangedSubview(view)
        view.removeFromSuperview()
        
        self.scrollviewWidth.constant = CGFloat((self.stackview.arrangedSubviews.count > 6 ? 6 : self.stackview.arrangedSubviews.count) * 40)
        
        self.selectUserList.remove(at: index)
        self.tableview.reloadData()
        
        if self.selectUserList.count == 0
        {
            self.rightBtn?.setTitle("完成", for: .normal)
        }else{
            self.rightBtn?.setTitle("完成(\(self.selectUserList.count)/10)", for: .normal)
        }
        rightBtn?.sizeToFit()
    }
}

extension TopicAttentionVC: UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource
{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataModelArr.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataModelArr[section].count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicAttentionCell", for: indexPath) as! TopicAttentionCell
        var data: StudentUserModel?
        data = dataModelArr[indexPath.section][indexPath.row]
        if self.selectUserList.contains(data!)
        {
            cell.setData(data!, isSelect: true)
        }else{
            cell.setData(data!, isSelect: false)
        }
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
        
        let user = self.dataModelArr[indexPath.section][indexPath.row]

        if self.selectUserList.contains(user)
        {
            let index = self.selectUserList.firstIndex(of: user)!

            self.removeView(index)
        }else{
            if self.selectUserList.count == 10
            {
                ToolClass.showToast("最多选择10人", .Failure)
                return
            }
            
            self.selectUserList.append(user)
            self.addUserToScroll(user)
            self.tableview.reloadData()
        }

    }
}
