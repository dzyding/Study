//
//  SearchPersonalVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/31.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class SearchKeyVC: BaseVC {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchRight: NSLayoutConstraint!
    
    @IBOutlet weak var hotView: UIView!
    @IBOutlet weak var hotViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var historyViewHeight: NSLayoutConstraint!
    
    var hotCollectionview: UICollectionView!
    var historyCollectionview: UICollectionView!
    
    var hotData = [String]()
    var histroyData = DataManager.historySearch()
        
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "搜索关键词"
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        
        setupSubviews()
        getHotKeys()
    }
    
    func setupSubviews()
    {
        let hotFlowLayout = ExpertiseCellSpaceFlowLayout()
        hotFlowLayout.estimatedItemSize = CGSize(width:100, height:25)
        
        hotCollectionview = UICollectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 32, height: self.hotViewHeight.constant), collectionViewLayout: hotFlowLayout)
        
        self.hotView.addSubview(hotCollectionview)
        
        
        hotCollectionview.delegate = self
        hotCollectionview.dataSource = self
        hotCollectionview.isScrollEnabled = false
        hotCollectionview.register(SearchKeyCell.self, forCellWithReuseIdentifier: "SearchKeyCell")
        hotCollectionview.backgroundColor = UIColor.clear
        
        
        
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
        DataManager.removeHistory()
        self.histroyData.removeAll()
        self.historyCollectionview.reloadData()
    }
    
    func getHotKeys()
    {
        let request = BaseRequest()
        request.url = BaseURL.SearchHot
        request.start { (data, error) in
            
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
      
            
            self.hotData = data?["hotKey"] as! [String]
            self.hotCollectionview.reloadData()
            self.hotCollectionview.performBatchUpdates({
                
            }) { (finish) in
                self.hotViewHeight.constant = self.hotCollectionview.contentSize.height + 10
                self.hotCollectionview.na_height = self.hotViewHeight.constant
            }
        }
    }
}

extension SearchKeyVC:UICollectionViewDelegate, UICollectionViewDataSource,UITextFieldDelegate
{

    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text?.isEmpty)!
        {
            DataManager.saveHistorySearch(textField.text!)
            let vc = SearchVC()
            vc.key = textField.text!
            vc.hbd_barHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  collectionView == self.hotCollectionview ? hotData.count : histroyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchKeyCell", for: indexPath) as! SearchKeyCell
        cell.lblContent.text =  collectionView == self.hotCollectionview ? hotData[indexPath.row] : histroyData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let key = collectionView == self.hotCollectionview ? hotData[indexPath.row] : histroyData[indexPath.row]
        let vc = SearchVC()
        vc.key = key
        vc.hbd_barHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
}
