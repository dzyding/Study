//
//  MotionLibraryVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import TableViewReloadAnimation
import HBDNavigationBar

class MotionLibraryVC: BaseVC {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var motionView: MotionGroupView!
    
    var currentCode = "MG10000"
    
    var isOther = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionView.delegate = self
        tableview.register(UINib(nibName: "MotionLibraryCell", bundle: nil), forCellReuseIdentifier: "MotionLibraryCell")
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getMotionList(loadmore ? (self!.currentPage)!+1 : 1)
        }
        tableview.srf_addRefresher(refresh)
        getMotionList(1)
    }
    
    
    @IBAction func searchAction(_ sender: UIButton) {
        let vc = SearchMotionVC()
        vc.hbd_barHidden = true
        let nav = HBDNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
//    @objc func addressBookAction() {
//        let addressView = AddressBookView.instanceFromNib()
//        addressView.frame = self.view.bounds
//        self.navigationController?.view.addSubview(addressView)
//    }
    
    func getMotionList(_ page: Int) {
        let request = BaseRequest()
        request.dic = ["motionPlanCode": currentCode]
        request.page = [page,50]
        request.isUser = true
        request.url = BaseURL.MotionList
        request.start { (data, error) in
            self.tableview.srf_endRefreshing()
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.page = data?["page"] as! Dictionary<String, Any>?
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            if self.currentPage == 1 {
                self.dataArr.removeAll()
                if listData.isEmpty {
                }else{
                    self.tableview.reloadData()
                }
                if self.currentPage! < self.totalPage!
                {
                    self.tableview.srf_canLoadMore(true)
                }else{
                    self.tableview.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage {
                self.tableview.srf_canLoadMore(false)
            }
            self.dataArr.append(contentsOf: listData)
            self.tableview.reloadData(
                with: .simple(duration: 0.75, direction: .rotation3D(type: .ironMan),
                              constantDelay: 0))
        }
    }
}

extension MotionLibraryVC:UITableViewDelegate,UITableViewDataSource,MotionSelectDelegate,MotionLibraryCellDelegate
{
    
    func detailAction(_ cell: MotionLibraryCell) {
        let indexPath = self.tableview.indexPath(for: cell)
        
        let vc = MotionDetailVC()
        vc.planCode = currentCode
        vc.dataDic = self.dataArr[(indexPath?.row)!]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func selectMotion(_ code: String) {
        if self.currentCode == code {
            return
        }
        self.currentCode = code
        getMotionList(1)
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
        print(dataArr[indexPath.row])
        
        if currentCode == "MG10006" {
            //有氧训练
            let vc = MotionTrainingCardioVC()
            vc.dataDic = dataArr[indexPath.row]
            vc.planCode = currentCode
            dzy_push(vc)
            return
        }
        let vc = MotionTrainingVC()
        vc.dataDic = dataArr[indexPath.row]
        vc.planCode = currentCode
        dzy_push(vc)
    }
}
