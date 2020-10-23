//
//  MotionTrainingVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol MotionTrainingRebackDelegate:NSObjectProtocol {
    
    func trainingData(_ actual:[String:Any], groupMotions:[[String:Any]]?)
}
class MotionTrainingVC: BaseVC {
    
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var targetGroupNumLB: UILabel!
    @IBOutlet weak var targetWeightLB: UILabel!
    @IBOutlet weak var targetFreLB: UILabel!
    @IBOutlet weak var targetHeight: NSLayoutConstraint!
    
    @IBOutlet weak var freMotionTrainingView: MotionTrainingView!
    @IBOutlet weak var weightMotionTrainingView: MotionTrainingView!
    @IBOutlet weak var waveView: SwiftSiriWaveformView!
    
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var groupNumLB: UILabel!
    @IBOutlet weak var weightLB: UILabel!
    @IBOutlet weak var freLB: UILabel!
    
    var index = 0.0
    var lastIndex = 0.0
    weak var timer:Timer?
    
    var target:[String:Any]?
    var coach:[String:Any]?
    
    var isOther = false
    
    var groupMotions = [[String:Any]]()
    
    var planCode = ""
    
    var change:CGFloat = 0.01
    var backgroundDate:Date?
    
    @IBOutlet weak var zizhongBtn: UIButton!
    @IBOutlet weak var selectWeightLB: UILabel!
    
    weak var delegate:MotionTrainingRebackDelegate?
    
    lazy var startBtn: UIButton = {
        let startBtn = UIButton(type: .custom)
        startBtn.frame = CGRect(x: ScreenWidth/2 - 145, y: ScreenHeight - CGFloat(60 + SafeBottom), width: 290, height: 50)
        startBtn.layer.cornerRadius = 25
        startBtn.titleLabel?.font = ToolClass.CustomFont(17)
        startBtn.backgroundColor = YellowMainColor
        startBtn.setTitle("开始", for: .normal)
        startBtn.setTitleColor(BackgroundColor, for: .normal)
        startBtn.addTarget(self, action: #selector(startAction(_:)), for: .touchUpInside)
        return startBtn
    }()
    
    lazy var againBtn: UIButton = {
        let againBtn = UIButton(type: .custom)
        againBtn.frame = CGRect(x: ScreenWidth/2 - 25, y: ScreenHeight - CGFloat(60 + SafeBottom) , width: 50, height: 50)
        againBtn.layer.cornerRadius = 25
        againBtn.titleLabel?.font = ToolClass.CustomFont(17)
        againBtn.backgroundColor = YellowMainColor
        againBtn.setTitle("再来一组", for: .normal)
        againBtn.setTitleColor(BackgroundColor, for: .normal)
        againBtn.addTarget(self, action: #selector(addGroup), for: .touchUpInside)
        againBtn.enableInterval = true
        return againBtn
    }()
    
    lazy var endBtn: UIButton = {
        let endBtn = UIButton(type: .custom)
        endBtn.frame = CGRect(x:ScreenWidth/2 - 25, y: ScreenHeight - CGFloat(60 + SafeBottom), width: 50, height: 50)
        endBtn.layer.cornerRadius = 25
        endBtn.titleLabel?.font = ToolClass.CustomFont(17)
        endBtn.layer.borderColor = Text1Color.cgColor
        endBtn.layer.borderWidth = 1
        endBtn.setTitle("完成训练", for: .normal)
        endBtn.setTitleColor(Text1Color, for: .normal)
        endBtn.addTarget(self, action: #selector(finishTraining(_:)), for: .touchUpInside)
        endBtn.enableInterval = true
        return endBtn
    }()
    
    lazy var headBar: UIImageView = {
        let headBtn = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        headBtn.layer.cornerRadius = 15
        headBtn.layer.masksToBounds = true
        headBtn.isUserInteractionEnabled = true
        //        headBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressBookAction)))
        return headBtn
    }()
    
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
            self.groupNumLB.textColor = Text1Color
            self.weightLB.textColor = Text1Color
            self.freLB.textColor = Text1Color
            
            self.targetGroupNumLB.text = "\(target!["groupNum"]!)组"
            self.targetWeightLB.text = "负重:\(target!["weight"]!)kg"
            self.targetFreLB.text = "\(target!["freNum"]!)个/组"
            self.headIV.setHeadImageUrl(self.coach!["head"] as! String)
        }
        
        self.freMotionTrainingView.setTotalNum(50, unit: 1)
        
        self.weightMotionTrainingView.setTotalNum(300, unit: 0.5)
        
        self.view.addSubview(self.startBtn)
        
        //进入前台调用
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (nofity) in
            let timeD = Date().timeIntervalSince(self?.backgroundDate ?? Date())
            print("时间差",timeD)
            if let index = self?.index, index > 0.0
            {
                self?.index = index + Double(timeD)
            }
        }
        //进入后台调用
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] (nofity) in
            self?.backgroundDate = Date()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = nil
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
    
    @IBAction func selectWeight(_ sender: UIButton) {
        selectWeightLB.isHidden = true
        weightMotionTrainingView.isHidden = false
        let tag = sender.tag
        switch tag {
        case 11:
            //自重
            self.zizhongBtn.isSelected = true
            weightMotionTrainingView.resetStyle()
            break
        case 12:
            //50kg
            weightMotionTrainingView.scrollToItem("50")
            break
        case 13:
            //100kg
            weightMotionTrainingView.scrollToItem("100")
            break
        case 14:
            //200kg
            weightMotionTrainingView.scrollToItem("200")
            break
        default:
            break
        }
    }
    
    @objc func startAction(_ sender:UIButton)
    {
        
        self.startBtn.setTitle("", for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.startBtn.frame = CGRect(x: self.view.na_width/2, y: self.startBtn.na_top, width: self.startBtn.na_height, height: self.startBtn.na_height)
            
        }) { (finish) in
            self.startBtn.removeFromSuperview()
            self.view.addSubview(self.endBtn)
            self.view.addSubview(self.againBtn)
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true);
            
            UIView.animate(withDuration: 0.25, animations: {
                self.endBtn.frame = CGRect(x: self.view.na_centerX - 172, y: self.endBtn.na_top, width: 168, height: 50)
                
                self.againBtn.frame = CGRect(x: self.view.na_centerX + 6, y: self.againBtn.na_top, width: 168, height: 50)
            })
            
        }
    }
    
    @objc func addGroup() {
        scaleAnimation()
        
        var num = Int(self.groupNumLB.text!)
        num = num! + 1
        self.groupNumLB.text = "\(num!)"
        
        let freNum = self.freMotionTrainingView.selectTex
        let weightNum = self.zizhongBtn.isSelected ? "0" : (self.weightMotionTrainingView.isHidden ? self.selectWeightLB.text! : self.weightMotionTrainingView.selectTex)
        
        let time = Int(index - lastIndex)
        
        lastIndex = index
        let dic:[String:Any] = ["freNum":Float(freNum)!,"weight":Float(weightNum)!,"rest":time]
        
        groupMotions.append(dic)
        
        var totalFreNum:Float = 0
        var totalWeightNum: Float = 0
        
        for item in groupMotions {
            let fre = item["freNum"] as! Float
            let weight = item["weight"] as! Float
            totalFreNum += fre
            totalWeightNum += weight
        }
        
        let aveFreNum = totalFreNum/Float(groupMotions.count)
        let aveWeightNum = totalWeightNum/Float(groupMotions.count)
        
        
        self.groupNumLB.text = "\(groupMotions.count)"
        self.weightLB.text = aveWeightNum.removeDecimalPoint
        self.freLB.text = "\(Int(aveFreNum))"
        
        if self.target != nil
        {
            let groupNum = (target!["groupNum"] as! NSNumber).floatValue
            let freNum = (target!["freNum"] as! NSNumber).floatValue
            let weight = (target!["weight"] as! NSNumber).floatValue
            
            if Float(groupMotions.count) >= groupNum
            {
                self.groupNumLB.textColor = UIColor.white
                
            }
            
            if aveWeightNum >= weight
            {
                self.weightLB.textColor = UIColor.white
            }
            
            if aveFreNum >= freNum
            {
                self.freLB.textColor = UIColor.white
            }
        }
    }
    
    func scaleAnimation()
    {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        
        animation.duration = animation.settlingDuration // 动画持续时间
        animation.repeatCount = 1 // 重复次数
        animation.autoreverses = false // 动画结束时执行逆动画
        animation.mass = 1
        animation.stiffness = 100
        animation.damping = 13
        animation.initialVelocity = 5
        animation.fillMode = CAMediaTimingFillMode.removed
        animation.isRemovedOnCompletion = true
        
        animation.fromValue = 0.8
        animation.toValue = 1
        
        self.againBtn.layer.add(animation, forKey: nil)
    }
    
    @objc func finishTraining(_ sender:UIButton) {
        if groupMotions.count == 0 {
            // 点击完成默认添加一组
            addGroup()
        }
        self.endBtn.isEnabled = false
        
        if self.delegate != nil {
            var actual = [String:Any]()
//            FIXME: 之前是 time
            actual["rest"] = Int(index)
            actual["groupNum"] = self.groupNumLB.text
            actual["freNum"] = self.freLB.text
            actual["weight"] = self.weightLB.text
            //记录回传
            self.delegate?.trainingData(actual, groupMotions: groupMotions)
            self.navigationController?.popViewController(animated: true)
            
        }else{
            publisMotion()
        }
    }
    
    @IBAction func weightInputAction(_ sender: UIButton) {
        let inputView = MotionWeightInputView.instanceFromNib()
        inputView.frame = ScreenBounds
        inputView.complete = { [weak self] (weight) in
            self?.selectWeightLB.text = weight
            self?.selectWeightLB.isHidden = false
            self?.weightMotionTrainingView.isHidden = true
            self?.zizhongBtn.isSelected = false
        }
        self.navigationController?.view.addSubview(inputView)
    }
    
    func publisMotion() {
        let motionId = dataDic.intValue("id") ?? 0
        let data: [[String : Any]] = [
            [
                "motionId" : motionId,
                "list" : groupMotions
            ]
        ]
        let dic = [
            "totalTime" : "\(Int(index))",
            "trainingData" : ToolClass.toJSONString(dict: data)
        ]
        let request = BaseRequest()
//        if isOther {
//            request.isOther = true
//            dic["coachUid"] = DataManager.userAuth()
//        }else{
            request.isUser = true
//        }
        request.dic = dic
        print(dic)
        request.url = BaseURL.AddTrainingData
        request.start { (data, error) in
            self.endBtn.isEnabled = true
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            print("success")
            ToolClass.showToast("发布成功", .Success)
            let time = Date().description
                .components(separatedBy: " ").first ?? ""
            NotificationCenter.default.post(
                name: Config.Notify_AddTrainingData,
                object: nil,
                userInfo: ["time" : time])
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.navigationController?.popViewController(animated: true)
            })

        }
    }
}
