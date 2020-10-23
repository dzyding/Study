//
//  MyMotionLibraryVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MyMotionLibraryVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var tableList: UITableView!
    
    var totalTemplate = 0
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的动作库"
        navigationItem.rightBarButtonItem = rightBtn
        tableList.register(UINib.init(nibName: "MyMotionLibraryCell", bundle: nil), forCellReuseIdentifier: "MyMotionLibraryCell")
        tableList.separatorColor = UIColor.ColorHex("#2e2e31")
        tableList.separatorInset.left = 76
                
        tableList.tableFooterView = UIView()
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData()
        }
        
        tableList.srf_addRefresher(refresh)
        
        getData()
        
        registObservers([
            Config.Notify_AddMotionData
        ]) { [weak self] (_) in
            self?.getData()
        }
    }
    
    func getData() {
        let request = BaseRequest()
        request.url = BaseURL.CoachMotionList
        request.isUser = true
        request.start { (data, error) in
            self.tableList.srf_endRefreshing()
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataArr.removeAll()
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            self.dataArr.append(contentsOf: listData)
            self.tableList.reloadData()
        }
    }
    
    func deleteMotionAPI(_ code:String) {
        let request = BaseRequest()
        request.dic = ["code" : code]
        request.url = BaseURL.DeleteMotion
        request.isUser = true
        request.start { (data, error) in
            self.tableList.srf_endRefreshing()
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("删除成功", .Success)
        }
    }
    
    @objc func addClick() {
        let vc = MyMotionAddVC.init(nibName: "MyMotionAddVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle("新增", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = dzy_Font(14)
        btn.addTarget(self,
                      action: #selector(addClick),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}

extension MyMotionLibraryVC: UITableViewDelegate, UITableViewDataSource, MyMotionLibraryCellDeleteDelegate {
    
    func deleteAction(_ cell:MyMotionLibraryCell) {
        
        let alert =  UIAlertController.init(title: "请确认是否删除？", message: "", preferredStyle: .alert)
        let actionN = UIAlertAction.init(title: "是", style: .default) { (_) in
            let index = self.tableList.indexPath(for: cell)
            let dic = self.dataArr[(index?.row)!]
            
            let code = dic["code"] as! String
            
            self.deleteMotionAPI(code)
            
            self.dataArr.remove(at: (index?.row)!)
            self.tableList.deleteRows(at: [index!], with: .right)
        }
        let actionY = UIAlertAction.init(title: "否", style: .cancel) { (_) in
            
        }
        alert.addAction(actionN)
        alert.addAction(actionY)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMotionLibraryCell", for: indexPath) as! MyMotionLibraryCell
        cell.delegate = self
        cell.setData(data: dataArr[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = MotionDetailVC()
        vc.isEdit = true
        vc.dataDic = self.dataArr[indexPath.row]
        
        let motionCode = vc.dataDic["code"] as! String
        vc.planCode = motionCode[0,6]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

