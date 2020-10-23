//
//  PlanSelectCardioMotionView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/6.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class PlanSelectCardioMotionView: UIView {
    
    @IBOutlet weak var timeMotionView: MotionTrainingView!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var centerYLC: NSLayoutConstraint!
    @IBOutlet weak var titleLB: UILabel!
    
    var delegate: PlanSelectMotionViewDelegate?
    
    var dataDic = [String:Any]()
    
    class func instanceFromNib() -> PlanSelectCardioMotionView {
        return UINib(nibName: "PlanSelectCardioMotionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlanSelectCardioMotionView
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.timeMotionView.selectBlock = { (selectStr) in
        }

    }
    
    func setInfoData(_ dic:[String:Any])
    {
        self.iconImg.setCoverImageUrl(dic["cover"] as! String)
        self.titleLB.text = dic["name"] as? String
        
        dataDic["motion"] = dic
        
        timeMotionView.setTotalNum(50, unit: 1)
    }
    
    //编辑 显示原来设置的值
    func setTargetData(data: [String: Any]) {
        
        let time = "\(data["time"] as! Int)"
        
        timeMotionView.selectTex = time
        
        //滑动到制定位置
        timeMotionView.selectInitIndex = timeMotionView.dataArr.firstIndex(of:time)!
        
    }
    
    
    
    
    class func show(_ view: PlanSelectCardioMotionView)
    {
        UIApplication.shared.keyWindow?.addSubview(view)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            view.centerYLC.constant = 0
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func close()
    {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.centerYLC.constant = 600
            self.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    
    @IBAction func addBtnClick(_ sender: Any) {
        //        [{"code":"MG10000M4274457","target":{"time":2}
        
        
        dataDic["target"] = ["time": Int(self.timeMotionView.selectTex)]
        
        self.delegate?.selectMotionTarget(dataDic)
        
        self.close()
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.close()
    }
    
}
