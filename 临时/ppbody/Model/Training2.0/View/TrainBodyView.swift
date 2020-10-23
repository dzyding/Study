//
//  TrainBodyView.swift
//  PPBody
//
//  Created by edz on 2019/12/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainBodyView: UIView, InitFromNibEnable {
    /// 体重 45kg
    @IBOutlet weak var weightLB: UILabel!
    /// 骨骼肌 29.6kg
    @IBOutlet weak var muscleLB: UILabel!
    /// 体脂肪 19.5kg
    @IBOutlet weak var fatLB: UILabel!
    /// BMI 17.6kg/m²
    @IBOutlet weak var BMILB: UILabel!
    /// PBF 43.3%
    @IBOutlet weak var PBFLB: UILabel!
    
    // 各部位身体图
    @IBOutlet weak var fFuIV: UIImageView!
    @IBOutlet weak var fJianIV: UIImageView!
    @IBOutlet weak var fTuiIV: UIImageView!
    @IBOutlet weak var fXiongIV: UIImageView!
    @IBOutlet weak var fShouIV: UIImageView!
    @IBOutlet weak var bBeiIV: UIImageView!
    @IBOutlet weak var bJianIV: UIImageView!
    @IBOutlet weak var bShouIV: UIImageView!
    @IBOutlet weak var bTuiIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [weightLB, muscleLB, fatLB, BMILB, PBFLB].forEach { (label) in
            label?.font = dzy_FontBlod(11)
        }
    }
    
    @IBAction func detailAction(_ sender: Any) {
        let vc = BodyIndexVC() //BodyStatusVC()// 
        parentVC?.dzy_push(vc)
    }
    
    func initUI(_ dic: [String : Any], bodys: [Int]) {
        let weight = dic.dicValue("weight")?
            .doubleValue("current") ?? 0
        let muscle = dic.dicValue("muscle")?
            .doubleValue("current") ?? 0
        let fat = dic.dicValue("fat")?
            .doubleValue("current") ?? 0
        let bmi = dic.dicValue("BMI")?
            .doubleValue("current") ?? 0
        let pbf = dic.dicValue("PBF")?
            .doubleValue("current") ?? 0
        weightLB.text = "体重 \(weight.decimalStr)kg"
        muscleLB.text = "骨骼肌 \(muscle.decimalStr)kg"
        fatLB.text = "体脂肪 \(fat.decimalStr)kg"
        BMILB.text = "BMI \(bmi.decimalStr)kg/m²"
        PBFLB.text = "PBF \(pbf.decimalStr)%"
        
        assert(bodys.count == 7)
        let x: CGFloat = 10.0
        // 胸
        if bodys[0] > 0 {
            let alpha = CGFloat(bodys[0]) / x
            fXiongIV.image = UIImage(named: "f_xiong")
            fXiongIV.alpha = alpha
        }else {
            fXiongIV.image = UIImage(named: "f_xiong_no")
            fXiongIV.alpha = 1
        }
        // 背
        if bodys[1] > 0 {
            let alpha = CGFloat(bodys[1]) / x
            bBeiIV.image = UIImage(named: "b_bei")
            bBeiIV.alpha = alpha
        }else {
            bBeiIV.image = UIImage(named: "b_bei_no")
            bBeiIV.alpha = 1
        }
        // 肩
        if bodys[2] > 0 {
            let alpha = CGFloat(bodys[2]) / x
            fJianIV.image = UIImage(named: "f_jian")
            fJianIV.alpha = alpha
            bJianIV.image = UIImage(named: "b_jian")
            bJianIV.alpha = alpha
        }else {
            fJianIV.image = UIImage(named: "f_jian_no")
            fJianIV.alpha = 1
            bJianIV.image = UIImage(named: "b_jian_no")
            bJianIV.alpha = 1
        }
        // 腹
        if bodys[3] > 0 {
            let alpha = CGFloat(bodys[3]) / x
            fFuIV.image = UIImage(named: "f_fu")
            fFuIV.alpha = alpha
        }else {
            fFuIV.image = UIImage(named: "f_fu_no")
            fFuIV.alpha = 1
        }
        // 手
        if bodys[4] > 0 {
            let alpha = CGFloat(bodys[4]) / x
            fShouIV.image = UIImage(named: "f_shou")
            fShouIV.alpha = alpha
            bShouIV.image = UIImage(named: "b_shou")
            bShouIV.alpha = alpha
        }else {
            fShouIV.image = UIImage(named: "f_shou_no")
            fShouIV.alpha = 1
            bShouIV.image = UIImage(named: "b_shou_no")
            bShouIV.alpha = 1
        }
        // 腿
        if bodys[5] > 0 {
            let alpha = CGFloat(bodys[5]) / x
            fTuiIV.image = UIImage(named: "f_tui")
            fTuiIV.alpha = alpha
            bTuiIV.image = UIImage(named: "b_tui")
            bTuiIV.alpha = alpha
        }else {
            fTuiIV.image = UIImage(named: "f_tui_no")
            fTuiIV.alpha = 1
            bTuiIV.image = UIImage(named: "b_tui_no")
            bTuiIV.alpha = 1
        }
    }
}
