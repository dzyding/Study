//
//  CoachPlanDetailVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import SpinKit


class CoachPlanDetailVC: BaseVC {
    
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveBtnWidth: NSLayoutConstraint!
    
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    var isEdit = false
    
    var planCode: String?
    
    var planOriginData = [[String:Any]]()
    
    var owner:[String:Any]?
    
    lazy var selectView: PlanSelectMotionView = {
        let v = PlanSelectMotionView.instanceFromNib()
        v.frame = ScreenBounds
        v.delegate = self
        return v
    }()
    
    lazy var selectCardioView: PlanSelectCardioMotionView = {
        let v = PlanSelectCardioMotionView.instanceFromNib()
        v.frame = ScreenBounds
        v.delegate = self
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = self.dataDic["name"] as? String
        
        planCode = self.dataDic["code"] as? String
        
        if isEdit{
            title = "动作列表"
            if planCode != nil {
                getData()
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addClick))
            }
        }else{
            if planCode != nil
            {
                getData()
                bottomMargin.constant = 0
            }
            
        }
        tableList.register(UINib.init(nibName: "CoachPlanDetailCell", bundle: nil), forCellReuseIdentifier: "CoachPlanDetailCell")
        
        //        let refresh = Refresher{ [weak self] (loadmore) -> Void in
        //            self?.getData()
        //        }
        
        //        tableList.srf_addRefresher(refresh)
        
        self.saveBtn.enableInterval = true
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        //完成编辑
        if dataArr.count == 0 {
            ToolClass.showToast("请选择训练动作", .Failure)
            return
        }
        
        //将列表数据做处理
        var planArr = [[String:Any]]()
        
        for item in dataArr {
            let dic: [String: Any] = ["code": (item["motion"] as! [String: Any])["code"] as Any, "target": item["target"] as Any]
            planArr.append(dic)
        }
        
        self.saveBtn.isEnabled = false
        //编辑上传planCode
        if  planCode != nil
        {
            self.dataDic["planCode"] = planCode
        }
        
        let img = self.dataDic["cover"] as? UIImage
        
        if img != nil
        {
            //需要上传图片
            let imgList = AliyunUpload.upload.uploadAliOSS([img!], type: .Plan) { (progress) in
                
            }
            self.dataDic["cover"] = imgList[0]
        }
        
        self.dataDic["plan"] = ToolClass.toJSONString(dict: planArr)
        
        self.dataDic.removeValue(forKey: "useNum")
        
        sender.setTitle("", for: .normal)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.saveBtnWidth.constant = 50
            self.view.layoutIfNeeded()
        }) { (finish) in
            if finish
            {
                let spinkit = RTSpinKitView(style: RTSpinKitViewStyle.styleArc, color: BackgroundColor)
                
                spinkit?.spinnerSize = 35
                sender.addSubview(spinkit!)
                spinkit?.snp.makeConstraints({ (make) in
                    make.center.equalToSuperview()
                })
                
                spinkit?.startAnimating()
                self.postPlanData()
            }
        }
        
        
    }
    
    
    //跳到新增动作列表
    @objc func addClick() {
        let vc = PlanSelectMotionVC(.edit)
        vc.setData(dataArr)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getData() {
        let request = BaseRequest()
        request.dic = ["planCode": self.planCode!]
        request.url = BaseURL.MotionForPlan
        request.start { (data, error) in
            
            self.tableList.srf_endRefreshing()
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            self.dataArr = listData
            self.planOriginData = listData
            self.tableList.reloadData()
            
        }
    }
    
    func deleteMotionForPlan(_ code: String)
    {
        let request = BaseRequest()
        request.dic = ["planCode":self.planCode!,"code":code]
        request.isUser = true
        request.url = BaseURL.DeleteMotionForPlan
        request.start { (data, error) in
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            ToolClass.showToast("动作删除成功", .Success)
        }
    }
    
    func postPlanData() {
        let request = BaseRequest()
        request.dic = self.dataDic as! [String : String]
        request.isUser = true
        request.url = BaseURL.EditMotionPlan
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.saveBtn.isEnabled = true
                self.saveBtn.setTitle("保存", for: .normal)
                self.saveBtn.subviews.last?.removeFromSuperview()
                UIView.animate(withDuration: 0.25, animations: {
                    self.saveBtnWidth.constant = 295
                    self.view.layoutIfNeeded()
                })
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            ToolClass.showToast("计划保存成功", .Success)
            
            NotificationCenter.default.post(name: Config.Notify_EditMotionPlanData, object: nil)
            
            ToolClass.dispatchAfter(after: 1, handler: {
                //返回到计划列表
                for vc in (self.navigationController?.children)!
                {
                    if vc is PlanListVC
                    {
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            })
        }
    }
    
}

extension CoachPlanDetailVC: UITableViewDelegate, UITableViewDataSource, PlanSelectMotionDelegate,PlanSelectMotionViewDelegate, CoachPlanDetailCellDelegate {

    
    
    //MARK: ------------PlanSelectMotionViewDelegate
    
    func detailAction(_ cell: CoachPlanDetailCell) {
        if cell.motion != nil
        {
            let motionCode = cell.motion!["code"] as! String
            
            let vc = MotionDetailVC()
            vc.planCode = ToolClass.planCodeFromMotion(motionCode)
            vc.dataDic = cell.motion!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func selectMotionTarget(_ dic: [String : Any]) {
        
        let motion = dic["motion"] as! [String:Any]
        let code = motion["code"] as! String
        
        for i in 0..<self.dataArr.count
        {
            var item = self.dataArr[i]
            let motionOrigin = item["motion"] as! [String:Any]
            let codeOrigin = motionOrigin["code"] as! String
            
            if codeOrigin == code
            {
                item["target"] = dic["target"]
                self.dataArr[i] = item
                self.tableList.reloadData()
                break
            }
        }
    }
    
    //MARK: CoachPlanDetailCellDelegate------
    func deleteAction(_ cell: CoachPlanDetailCell) {
        let indexPath = self.tableList.indexPath(for: cell)
        
        if (self.dataDic["code"] as? String) != nil
        {
            //删除接口
            let dic = self.dataArr[(indexPath?.row)!]
            let motion = dic["motion"] as! [String:Any]
            let motionCode = motion["code"] as! String
            for item in self.planOriginData
            {
                let motionOrigin = item["motion"] as! [String:Any]
                let motionCodeOrigin = motionOrigin["code"] as! String
                if motionCodeOrigin == motionCode
                {
                    self.deleteMotionForPlan(motion["code"] as! String)
                    break
                }
            }
        }
        
        self.dataArr.remove(at: (indexPath?.row)!)
        self.tableList.deleteRows(at: [indexPath!], with: .right)
    }
    
    
    //MARK: PlanSelectMotionDelegate------
    func returnMotions(_ data: [[String : Any]]) {
        // 不需要了
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachPlanDetailCell", for: indexPath) as! CoachPlanDetailCell
        cell.setData(data: dataArr[indexPath.row], delete: isEdit)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = self.dataArr[indexPath.row]
        let motion = dic["motion"] as! [String:Any]
        let target = dic["target"] as! [String:Any]
        
        
        if isEdit
        {
            let code = motion["code"] as! String
            
            if ToolClass.isCardio(code)
            {
                selectCardioView.setInfoData(motion)
                selectCardioView.setTargetData(data: target)
                PlanSelectCardioMotionView.show(selectCardioView)
                
            }else{
                selectView.setInfoData(motion)
                selectView.setTargetData(data: target)
                PlanSelectMotionView.show(selectView)
            }
            
        }else{
            let motionCode = motion["code"] as! String
            
            if motionCode.contains("MG10006")
            {
                
                //有氧训练
                let vc = MotionTrainingCardioVC()
                vc.dataDic = motion
                vc.target = target
                vc.coach = owner
                vc.planCode = planCode!
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            let vc = MotionTrainingVC()
            vc.dataDic = motion
            vc.target = target
            vc.coach = owner
            vc.planCode = planCode!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

