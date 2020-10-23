//
//  RulerVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/18.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol BodyStatusRulerSelectDelegate: NSObjectProtocol {
    func selectRuler(_ type: BodyStatusType, isChange:Bool, value: CGFloat)
}

class BodyStatusRulerVC: BaseVC {
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    @IBOutlet weak var srollView: UIScrollView!
    @IBOutlet weak var lblLow: UILabel!
    @IBOutlet weak var lblHigh: UILabel!
    @IBOutlet weak var lblNormal: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var imgType: UIImageView!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblDes: UILabel!
    @IBOutlet weak var viewCircleLow: UIView!
    @IBOutlet weak var viewCircleHigh: UIView!
    @IBOutlet weak var viewCircleNormal: UIView!
    @IBOutlet weak var rulerView: NaRulerView!
    
    var bodyStatusType : BodyStatusType!
    
    let kgUnit = [BodyStatusType.Weight, BodyStatusType.Muscle, BodyStatusType.Fat]
    
    //获取学员的性别
    var sex = DataManager.getMemberSex()
    
    var unit = "kg"
    
    var originValue:CGFloat = -1
    
    weak var delegate:BodyStatusRulerSelectDelegate?
    
    convenience init(_ bodyStatusType: BodyStatusType) {
        self.init()
        self.bodyStatusType = bodyStatusType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        if !dataDic.isEmpty {
            setData(dataDic)
        }
    }
    
    func initUI() {
        lblDes.text = getTip(bodyStatusType)
        lblType.text = getTitleFromType(bodyStatusType)
        rulerView.delegate = self
        if !(bodyStatusType == .Weight || bodyStatusType == .Muscle || bodyStatusType == .Fat)
        {
            topView.isHidden = true
            topMargin.constant = -30
            unit = "cm"
            let scale = getRulerSize(bodyStatusType)
            rulerView.showRulerScrollViewWithCount(scale[0], max: scale[1], lowCount: nil, highCount: nil, average: 0.1, currentValue: CGFloat(scale[2]), smallMode: true)
            
            lblValue.text = "\(CGFloat(scale[2]))" + unit
        }else{
            let scale = getRulerSize(bodyStatusType)
            rulerView.showRulerScrollViewWithCount(scale[0], max: scale[1], lowCount: nil, highCount: nil, average: 0.1, currentValue: CGFloat(scale[2]), smallMode: true)
            lblValue.text = "\(CGFloat(scale[2]))" + unit
        }
        if sex == nil {
            let user = DataManager.userInfo()
            let sex = user!["sex"] as! Int
            self.imgType.image = getIconImageFromType(bodyStatusType, sex: sex)
        }else{
            self.imgType.image = getIconImageFromType(bodyStatusType, sex: self.sex!)
        }
        
    }
    
    func setData(_ body: [String:Any])
    {
        switch bodyStatusType {
        case .Weight?:
            if let dic = body["weight"] as? [String:Any]
            {
                refreshRuler(dic,currentValue: 0)
            }
            break
        case .Muscle?:
            if let dic = body["muscle"] as? [String:Any]
            {
                refreshRuler(dic,currentValue: 0)
            }
            break
        case .Fat?:
            if let dic = body["fat"] as? [String:Any]
            {
                refreshRuler(dic,currentValue: 0)
            }
            break
        case .Bust?:
            if let current = body["bust"] as? NSNumber
            {
                refreshRuler(nil,currentValue: CGFloat(current.floatValue))
            }
            break
            
        case .Arm?:
            if let current = body["arm"] as? NSNumber
            {
                refreshRuler(nil,currentValue: CGFloat(current.floatValue))
            }
            break
        case .Waist?:
            if let current = body["waist"] as? NSNumber
            {
                refreshRuler(nil,currentValue: CGFloat(current.floatValue))
            }
            break
        case .Hipline?:
            if let current = body["hipline"] as? NSNumber
            {
                refreshRuler(nil,currentValue: CGFloat(current.floatValue))
            }
            break
        case .Thigh?:
            if let current = body["thigh"] as? NSNumber
            {
                refreshRuler(nil,currentValue: CGFloat(current.floatValue))
            }
            break
        default:
            break
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshRuler(_ dic: [String:Any]?, currentValue: CGFloat)
    {
        var lowValue:CGFloat? = nil
        var highValue:CGFloat? = nil
        var current = currentValue
        if dic != nil
        {
            lowValue = CGFloat((dic!["min"] as! NSNumber).floatValue)
            highValue = CGFloat((dic!["max"] as! NSNumber).floatValue)
            current = CGFloat((dic!["current"] as! NSNumber).floatValue)
        }
        
        self.originValue = current
        
        rulerView.refresh(lowCount: lowValue, highCount: highValue, currentValue: current)
        
        if (bodyStatusType == .Weight || bodyStatusType == .Muscle || bodyStatusType == .Fat)
        {
            self.lblLow.text = String(rulerView.min()) + "~" + Float(rulerView.lowValue()).removeDecimalPoint + "kg"
            self.lblNormal.text = Float(rulerView.lowValue()).removeDecimalPoint + "~" + Float(rulerView.highValue()).removeDecimalPoint + "kg"
            self.lblHigh.text = Float(rulerView.highValue()).removeDecimalPoint + "~" + String(rulerView.max()) + "kg"
        }
    }
    
    
    func getTip(_ type: BodyStatusType) -> String
    {
        switch type {
        case .Bust:
            return "经乳点水平环绕胸部一周的数据\n(呼吸末时胸部最丰满尺寸)"
        case .Arm:
            return "环绕肱二头肌最膨隆处一周的数据\n(手臂自然下垂时的尺寸)"
        case .Thigh:
            return "环绕大腿内侧肌肉最彭隆处一周的数据\n(腿部最丰满尺寸)"
        case .Waist:
            return "经肚脐水平环绕腹部一周的数据\n(呼吸末时腹部最小尺寸)"
        case .Hipline:
            return "环绕臀部向后最突出部位一周的数据\n(臀部最丰满尺寸)"
        default:
            return ""
        }
    }
    
    func getTitleFromType(_ type: BodyStatusType) -> String
    {
        switch type {
        case .Weight:
            return "体重"
        case .Muscle:
            return "骨骼肌"
        case .Fat:
            return "体脂肪"
        case .Bust:
            return "胸围"
        case .Arm:
            return "臂围"
        case .Waist:
            return "腰围"
        case .Hipline:
            return "臀围"
        case .Thigh:
            return "腿围"
        }
    }
    
    func getIconImageFromType(_ type: BodyStatusType, sex: Int) -> UIImage
    {
        switch type {
        case .Weight:
            return UIImage(named: "body_weight")!
        case .Muscle:
            return UIImage(named: "body_muscle")!
        case .Fat:
            return UIImage(named: "body_fat")!
        case .Bust:
            return sex == 10 ? UIImage(named: "body_bust_boy")! : UIImage(named: "body_bust_girl")!
        case .Arm:
            return sex == 10 ? UIImage(named: "body_arm_boy")! : UIImage(named: "body_arm_girl")!
        case .Waist:
            return sex == 10 ? UIImage(named: "body_waist_boy")! : UIImage(named: "body_waist_girl")!
        case .Hipline:
            return sex == 10 ? UIImage(named: "body_hipline_boy")! : UIImage(named: "body_hipline_girl")!
        case .Thigh:
            return sex == 10 ? UIImage(named: "body_thigh_boy")! : UIImage(named: "body_thigh_girl")!
        }
    }
    
    func getRulerSize(_ type: BodyStatusType) -> [Int]
    {
        switch type {
        case .Weight:
            return [30,130,45]
        case .Muscle:
            return [10,120,30]
        case .Fat:
            return [0,100,20]
        case .Bust:
            return [70,180,90]
        case .Arm:
            return [10,100,20]
        case .Waist:
            return  [30,170,70]
        case .Hipline:
            return [30,170,70]
        case .Thigh:
            return [30,130,60]
        }
    }
    
}


extension BodyStatusRulerVC : NaRulerViewDelegate {
    func naRulerView(scroll: NaRulerScrollView) {
        
        let current = Float(scroll.rulerValue + CGFloat(scroll.min)).format(f: 1)
        
        self.lblValue.text = String(format: "%.1f"+unit, current)

        self.delegate?.selectRuler(bodyStatusType, isChange: self.originValue != CGFloat(current), value: CGFloat(current))
    }
}
