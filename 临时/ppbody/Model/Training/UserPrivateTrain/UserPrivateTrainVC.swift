//
//  UserPrivateTrainVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class UserPrivateTrainVC: BaseVC {
    
    @IBOutlet weak var tableList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()


        tableList.register(UINib.init(nibName: "UserPrivateTrainCell", bundle: nil), forCellReuseIdentifier: "UserPrivateTrainCell")
        tableList.rowHeight = 72.0 + (ScreenWidth - 3*16)/2.0 + 16.0
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData()
        }
        
        tableList.srf_addRefresher(refresh)
        
        getData()
        
    }

    func getData() {
        let request = BaseRequest()
        request.url = BaseURL.MyMotionPlan
        request.isUser = true
        request.start { (data, error) in
            
            self.tableList.srf_endRefreshing()
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let listData = data?["planList"] as! Array<Dictionary<String,Any>>
            self.dataArr.removeAll()
            self.dataArr.append(contentsOf: listData)
            self.tableList.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension UserPrivateTrainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableList.dequeueReusableCell(withIdentifier: "UserPrivateTrainCell", for: indexPath) as! UserPrivateTrainCell
        cell.selectionStyle = .none
        cell.setData(data: dataArr[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let dic = dataArr[indexPath.row]
//        let vc = CoachPlanDetailVC()
//        vc.dataDic = dic
//        self.navigationController?.pushViewController(vc, animated: true)
//        
    }
}

