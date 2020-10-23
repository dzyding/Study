//
//  PlanSelectMotionView.swift
//  PPBody
//
//  Created by Mike on 2018/7/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit


protocol PlanSelectMotionViewDelegate:NSObjectProtocol {
    func selectMotionTarget(_ dic:[String:Any])
}

class PlanSelectMotionView: UIView {

    @IBOutlet weak var weightMotionView: MotionTrainingView!
    @IBOutlet weak var numOfGroupMotionView: MotionTrainingView!
    @IBOutlet weak var groupMotionView: MotionTrainingView!
    @IBOutlet weak var numLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var groupLbl: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var centerYLC: NSLayoutConstraint!
    @IBOutlet weak var titleLB: UILabel!
    
    var delegate: PlanSelectMotionViewDelegate?
    
    var dataDic = [String:Any]()
    
    class func instanceFromNib() -> PlanSelectMotionView {
        return UINib(nibName: "PlanSelectMotionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlanSelectMotionView
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.weightMotionView.selectBlock = {[weak self] (selectStr) in
            self?.weightLbl.text = selectStr == "自重" ? "0" : selectStr
        }
        self.numOfGroupMotionView.selectBlock = {[weak self] (selectStr) in
            self?.numLbl.text = selectStr
        }
        self.groupMotionView.selectBlock = {[weak self] (selectStr) in
            self?.groupLbl.text = selectStr
        }
        
    }

    func setInfoData(_ dic:[String:Any]) {
        iconImg.setCoverImageUrl(dic.stringValue("cover"))
        titleLB.text = dic.stringValue("name")
        dataDic["motion"] = dic
        groupMotionView.setTotalNum(50, unit: 1)
        numOfGroupMotionView.setTotalNum(50, unit: 1)
        weightMotionView.setTotalNum(300, unit: 0.5, zero: true)
    }
    
    //编辑 显示原来设置的值
    func setTargetData(data: [String: Any]) {
        
        let weight = (data["weight"] as! NSNumber).floatValue.removeDecimalPoint
        let freNum = "\(data["freNum"] as! Int)"
        let groupNum = "\(data["groupNum"] as! Int)"
        
        weightMotionView.selectTex = weight
        numOfGroupMotionView.selectTex = freNum
        groupMotionView.selectTex = groupNum
        
        //滑动到制定位置
        weightMotionView.selectInitIndex = weightMotionView
            .dataArr.firstIndex(of:weight == "0" ? "自重" : weight )!
        numOfGroupMotionView.selectInitIndex = numOfGroupMotionView.dataArr.firstIndex(of: freNum)!
        groupMotionView.selectInitIndex = groupMotionView.dataArr.firstIndex(of: groupNum)!
        
    }
    
    class func show(_ view: PlanSelectMotionView)
    {
        UIApplication.shared.keyWindow?.addSubview(view)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            view.centerYLC.constant = 0
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func close() {
        UIView.animate(withDuration: 0.25, animations: {
            self.centerYLC.constant = 600
            self.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    
    @IBAction func addBtnClick(_ sender: Any) {
//        [{"code":"MG10000M4274457","target":{"groupNum":2,"freNum":12,"weight":30}
        
        let groupNum: Int = Int(self.groupLbl.text!) ?? 0
        let freNum: Int = Int(self.numLbl.text!) ?? 0
        let weight: Float = Float(self.weightLbl.text!) ?? 0
        
        dataDic["target"] = ["groupNum": groupNum, "freNum": freNum, "weight": weight]
        
        self.delegate?.selectMotionTarget(dataDic)
        
        self.close()
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.close()
    }
    
}
