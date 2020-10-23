//
//  TopicTagVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

enum TagListType {
    /// 所有的
    case list
    /// 发布时选择的
    case select
}

protocol SelectTopicTagDelegate: NSObjectProtocol{
    func selectTag(_ name: String)
}

class TopicTagVC: BaseVC {
    
    private let type: TagListType
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchTV: UITableView!
    
    weak var delegate: SelectTopicTagDelegate?
    
    var hotArr = [[String:Any]]()
    
    let tableviewHead = UINib(nibName: "TopicTagHead", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopicTagHead
    
    init(_ type: TagListType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let holder = NSAttributedString(string: "Search",
          attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        searchTF.attributedPlaceholder = holder
        searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        initUI()
        getHotData()
    }
    
    private func initUI() {
        switch type {
        case .select:
            title = "选择挑战"
            tableviewHead.delegate = self.delegate
            tableview.tableHeaderView = tableviewHead
        case .list:
            title = "话题列表"
        }
        
        [tableview, searchTV].forEach { (tbView) in
            tbView?.dzy_registerCellNib(TopicTagImgCell.self)
            tbView?.dzy_registerCellNib(TopicTagCell.self)
        }
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        searchTV.srf_addRefresher(refresh)
    }
    
    @objc func textFieldDidChange(_ textfield : UITextField)
    {
        search(by: textfield.text!)
    }
    
    //搜索数据
    func search(by key: String) {
        if key.count != 0 {
            searchTV.isHidden = false
            getData(1)
        }else{
            searchTV.isHidden = true
        }
    }
    
    func getHotData() {
        let request = BaseRequest()
        request.page = [1, 30]
        request.url = type == .select ? BaseURL.HotTag : BaseURL.TagList
        request.start { (data, error) in
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            self.hotArr = listData
            self.tableview.reloadData()
        }
    }
    
    func getData(_ num: Int) {
        let request = BaseRequest()
        request.dic = ["key" : searchTF.text!]
        request.page = [num, 20]
        request.url = BaseURL.SearchTag
        request.start { (data, error) in
            self.searchTV.srf_endRefreshing()
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.page = data?["page"] as! Dictionary<String, Any>?
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            if self.currentPage == 1 {
                self.dataArr.removeAll()
                if listData.isEmpty {
                }else{
                    self.searchTV.reloadData()
                }
                if self.currentPage! < self.totalPage! {
                    self.searchTV.srf_canLoadMore(true)
                }else{
                    self.searchTV.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage {
                self.searchTV.srf_canLoadMore(false)
            }
            self.dataArr.append(contentsOf: listData)
            self.searchTV.reloadData()
        }
    }
}

extension TopicTagVC: UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.tableview ? hotArr.count : dataArr.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic = tableView == self.tableview ? hotArr[indexPath.row] : dataArr[indexPath.row]
        let cover = dic["cover"] as! String
        var tableCell: UITableViewCell
        if cover == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicTagCell", for: indexPath) as! TopicTagCell
            cell.setData(dic)
            tableCell = cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicTagImgCell", for: indexPath) as! TopicTagImgCell
            cell.setData(dic)
            tableCell = cell
        }
        return tableCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = tableView == self.tableview ? hotArr[indexPath.row] : dataArr[indexPath.row]
        switch type {
        case .select:
            delegate?.selectTag(dic["name"] as! String)
            navigationController?.popViewController(animated: true)
        case .list:
            dic.stringValue("name").flatMap({
                let vc = TopicTagDetailVC()
                vc.tag = $0
                dzy_push(vc)
            })
        }
    }
}
