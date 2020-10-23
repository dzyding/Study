//
//  MotionTrainingCardioVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/2.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation


class MotionTrainingCardioVC: BaseVC {
    
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!

    @IBOutlet weak var targetTimeLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var waveView: SwiftSiriWaveformView!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var leftCenterX: NSLayoutConstraint!
    
    @IBOutlet weak var rightCenterX: NSLayoutConstraint!
    @IBOutlet weak var recordBtn: UIButton!
    
    var index = 0.0
    var lastIndex = 0.0
    
    var timer:Timer!
    var isOther = false
    var planCode = ""
    var change:CGFloat = 0.01

    
    var target:[String:Any]?
    var coach:[String:Any]?
    
    var backgroundDate:Date?
    
     weak var delegate:MotionTrainingRebackDelegate?
    
    lazy var headBar: UIImageView = {
        let headBtn = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        headBtn.layer.cornerRadius = 15
        headBtn.layer.masksToBounds = true
        headBtn.isUserInteractionEnabled = true
        //        headBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressBookAction)))
        return headBtn
    }()
    
    @IBAction func trainingAction(_ sender: UIButton) {
        if sender == self.rightBtn
        {
            if sender.titleLabel?.text == "开始"
            {
                self.recordBtn.isHidden = true
                sender.setTitle("完成", for: .normal)
                self.leftBtn.isHidden = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.leftCenterX.constant = -75
                    self.rightCenterX.constant = 75
                    self.view.layoutIfNeeded()
                }) { (finish) in
                    self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true);
                }
            }else{
                //完成训练
                self.rightBtn.isEnabled = false
                publisMotion(Int(index))
            }
        }else if sender == self.leftBtn
        {
            if sender.titleLabel?.text == "暂停"
            {
                self.timer.fireDate = Date.distantFuture
                sender.setTitle("开始", for: .normal)

            }else{
                sender.setTitle("暂停", for: .normal)

                self.timer.fireDate = Date()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ToolClass.removeChildController(self, removeClass: MotionDetailVC.self)
        //判断是否是学员
        if DataManager.memberInfo() != nil
        {
            isOther = true
            addRightBar()
        }
        
        self.title = self.dataDic["name"] as? String
        self.waveView.density = 1.0
        
        
        if self.target == nil
        {
            self.targetView.isHidden = true
        }else{
            // 有私教目标
            
            let time = target!["time"] as! Int
            
            self.targetTimeLB.text = "\(time)分钟"
            self.headIV.setHeadImageUrl(self.coach!["head"] as! String)
        }
        
        //进入前台调用
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (nofity) in
            let timeD = Date().timeIntervalSince(self.backgroundDate ?? Date())
            print("时间差",timeD)
            if self.index > 0
            {
                self.index = self.index + Double(timeD)
            }
        }
        //进入后台调用
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (nofity) in
            self.backgroundDate = Date()
        }
    }
    
    
    func addRightBar()
    {
        let rightview = UIView(frame: self.headBar.bounds)
        rightview.addSubview(self.headBar)
        let rightbar = UIBarButtonItem(customView: rightview)
        self.headBar.setHeadImageUrl(DataManager.getMemberHead()!)
        self.navigationItem.rightBarButtonItem = rightbar
    }
    
    @objc func updateTime()
    {
        index += 0.01
        
        if self.waveView.amplitude <= self.waveView.idleAmplitude || self.waveView.amplitude > 1.0 {
            self.change *= -1.0
        }
        self.waveView.amplitude += self.change
        
        let seconds = Int(index) % 60
        let minutes = Int(index) / 60
        let hour = Int(index) / 3600
        self.timeLB.text = String(format: "%02d:%02d:%02d",hour, minutes,seconds)
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        let inputView = MotionCardioInputView.instanceFromNib()
        inputView.frame = ScreenBounds
        inputView.complete = { [weak self] (time) in
            self?.publisMotion(time * 60)
            self?.rightBtn.isEnabled = false
        }
        self.navigationController?.view.addSubview(inputView)
    }
    
    func publisMotion(_ min: Int)
    {
        
        if self.delegate != nil
        {
            
            self.delegate?.trainingData(["time":min], groupMotions: nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let motionCode = self.dataDic["code"] as! String
        
        var dic = ["motionCode": motionCode, "motionPlanCode": planCode, "time":"\(min)"]
        
        let request = BaseRequest()
        if isOther
        {
            request.isOther = true
            dic["coachUid"] = DataManager.userAuth()
        }else{
            request.isUser = true
        }
//        FIXME: 待改
        request.dic = dic
        request.url = BaseURL.AddTrainingData
        request.start { (data, error) in
            
            self.rightBtn.isEnabled = true
            
            guard error == nil else
            {
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            ToolClass.showToast("发布成功", .Success)
            
            NotificationCenter.default.post(name: Config.Notify_AddTrainingData, object: nil)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.navigationController?.popViewController(animated: true)
            })
            
        }
    }
}
