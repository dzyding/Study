//
//  SearchMotionVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/9/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol SearchMotionVCDelegate:NSObjectProtocol {
    func selectMotion(_ motion: [String:Any])
}

class SearchMotionVC: BaseVC {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchRight: NSLayoutConstraint!
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var historyViewHeight: NSLayoutConstraint!
    
    var historyCollectionview: UICollectionView!
    
    var histroyData = DataManager.historyMotionSearch()
    
    var key = ""
    
    weak var delegate:SearchMotionVCDelegate?
    
    lazy var emptyView:EmptyView = {
        let emptyview = UINib(nibName: "EmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyView
        emptyview.setStyle(EmptyStyle.SearchEmpty)
        return emptyview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "搜索动作关键词"
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        self.searchTF.addTarget(self, action: #selector(startSearch), for: UIControl.Event.editingChanged)
        setupSubviews()
        
        
        self.tableview.register(UINib(nibName: "MotionLibraryCell", bundle: nil), forCellReuseIdentifier: "MotionLibraryCell")
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getSearchKeys(loadmore ? (self!.currentPage)!+1 : 1)
        }
        tableview.srf_addRefresher(refresh)
    }
    
    func setupSubviews()
    {

        let historyFlowLayout = ExpertiseCellSpaceFlowLayout()
        historyFlowLayout.estimatedItemSize = CGSize(width:100, height:25)
        
        historyCollectionview = UICollectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 32, height: self.historyViewHeight.constant), collectionViewLayout: historyFlowLayout)
        
        self.historyView.addSubview(historyCollectionview)
        
        
        historyCollectionview.delegate = self
        historyCollectionview.dataSource = self
        historyCollectionview.isScrollEnabled = false
        historyCollectionview.register(SearchKeyCell.self, forCellWithReuseIdentifier: "SearchKeyCell")
        historyCollectionview.backgroundColor = UIColor.clear
        
        
        historyCollectionview.performBatchUpdates({
            historyCollectionview.reloadData()
        }) { (finish) in
            self.historyViewHeight.constant = self.historyCollectionview.contentSize.height + 10
            self.historyCollectionview.na_height = self.historyViewHeight.constant
        }
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        super.backAction()
    }

    
    @IBAction func deleteAction(_ sender: UIButton) {
        DataManager.removeMotionHistory()
        self.histroyData.removeAll()
        self.historyCollectionview.reloadData()
    }
    
    @objc func startSearch()
    {
        let searchContent = self.searchTF.text
        
        if searchContent == ""
        {
            self.tableview.isHidden = true
            self.dataArr.removeAll()
            self.tableview.reloadData()
        }
    }
    
    func getSearchKeys(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["key": self.key]
        request.page = [page,20]
        request.isUser = true
        request.url = BaseURL.SearchMotion
        request.start { (data, error) in
            
             self.tableview.srf_endRefreshing()
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            
            if self.currentPage == 1
            {
                
                self.dataArr.removeAll()
                if listData.isEmpty
                {
                    if self.emptyView.superview == self.tableview
                    {
                        return
                    }
                    self.tableview.addSubview(self.emptyView)
                    self.emptyView.center = CGPoint(x: self.tableview.bounds.width/2, y: self.tableview.bounds.height/2 - 40)
                    
                    return
                    
                }else{
                    self.emptyView.removeFromSuperview()
                }
                
                if self.currentPage! < self.totalPage!
                {
                    self.tableview.srf_canLoadMore(true)
                }else{
                    self.tableview.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage
            {
                self.tableview.srf_canLoadMore(false)
            }
            self.dataArr.append(contentsOf: listData)
            self.tableview.reloadData()
        }
    }
}



extension SearchMotionVC:UICollectionViewDelegate, UICollectionViewDataSource,UITextFieldDelegate
{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text?.isEmpty)!
        {
            DataManager.saveMotionHistorySearch(textField.text!)

            self.key = textField.text!
            self.tableview.isHidden = false
            if self.emptyView.superview == self.tableview
            {
                self.emptyView.removeFromSuperview()
            }
            self.getSearchKeys(1)
            
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  histroyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchKeyCell", for: indexPath) as! SearchKeyCell
        cell.lblContent.text =  histroyData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.key = histroyData[indexPath.row]
 
        self.searchTF.text = self.key
        self.tableview.isHidden = false
        if self.emptyView.superview == self.tableview
        {
            self.emptyView.removeFromSuperview()
        }
        self.getSearchKeys(1)
    }
}

typealias SearchMotionList = SearchMotionVC

extension SearchMotionList:UITableViewDelegate,UITableViewDataSource,MotionLibraryCellDelegate
{
    func detailAction(_ cell: MotionLibraryCell) {
        let indexPath = self.tableview.indexPath(for: cell)
        let motion = self.dataArr[indexPath!.row]
        let code = motion["code"] as! String
        let vc = MotionDetailVC()
        let end = code.index(code.startIndex, offsetBy: 6)
        vc.planCode = String(code[...end])
        vc.dataDic = motion
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MotionLibraryCell", for: indexPath) as! MotionLibraryCell
        cell.setData(self.dataArr[indexPath.row])
        cell.delegate = self
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let motion = self.dataArr[indexPath.row]
        
        if self.delegate != nil
        {
            self.delegate?.selectMotion(motion)
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let code = motion["code"] as! String
        let end = code.index(code.startIndex, offsetBy: 6)
        let plancode = String(code[...end])
        if plancode == "MG10006"
        {
            //有氧训练
            let vc = MotionTrainingCardioVC()
            vc.dataDic = motion
            vc.planCode = plancode
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let vc = MotionTrainingVC()
        vc.dataDic = motion
        vc.planCode = plancode
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
