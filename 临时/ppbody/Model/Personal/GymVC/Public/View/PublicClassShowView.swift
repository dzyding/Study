//
//  PublicClassShowView.swift
//  PPBody
//
//  Created by edz on 2019/7/26.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol PublicClassShowViewDeleagate: class {
    func classShowView(_ classShowView: PublicClassShowView,
                       didClickQrBtn btn: UIButton,
                       code: String?)
    
    func classShowView(_ classShowView: PublicClassShowView,
                       didClickHideBtn btn: UIButton)
}

class PublicClassShowView: UIView {
    
    weak var delegate: PublicClassShowViewDeleagate?
    
    private let waitColor = dzy_HexColor(0xE6A23C)
    
    private let ingColor = dzy_HexColor(0xF02E8D)
    
    private let endColor = dzy_HexColor(0x46454D)
    
    private var color = UIColor.white

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var typeLB: UILabel!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    private var code: String?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        transform = transform.translatedBy(x: -ScreenWidth, y: 0)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 1) {
            self.transform = .identity
        }
    }

    func initUI(_ data: [String : Any]) {
        code = data.stringValue("code")
        nameLB.text = data.stringValue("ptName")
        if let head = data.stringValue("head") {
            iconIV.dzy_setCircleImg(
                head,
                180,
                placeholder: UIImage(named: "gym_class_coachicon")
            )
        }
        if let start = data.intValue("start"),
            let end = data.intValue("end")
        {
            let startStr = ToolClass.getTimeStr(start)
            let endStr = ToolClass.getTimeStr(end)
            timeLB.text = startStr + " - " + endStr
        }
        
        let status = data.intValue("status") ?? 0
        switch status {
        case 10:
            typeLB.text = "待上课"
            color = waitColor
        case 20:
            typeLB.text = "上课中"
            color = ingColor
        default: // 30
            typeLB.text = "已结束"
            color = endColor
        }
        typeLB.backgroundColor = color
        bgView.layer.insertSublayer(cLayer, at: 0)
        bgView.layer.insertSublayer(aLayer, at: 0)
        if status == 20 {
            aLayer.add(circleAniGroup, forKey: "animationGroup")
        }
    }
    
    func clean() {
        cLayer.removeFromSuperlayer()
        aLayer.removeFromSuperlayer()
        aLayer.removeAllAnimations()
    }
    
    @IBAction func qrAction(_ sender: UIButton) {
        delegate?.classShowView(self,
                                didClickQrBtn: sender,
                                code: code ?? "")
    }
    
    @IBAction func hideAction(_ sender: UIButton) {
        delegate?.classShowView(self, didClickHideBtn: sender)
    }
    
    //    MARK: - 懒加载
    /// 这个是动画 layer
    private lazy var aLayer: CAShapeLayer = {
        let awidth: CGFloat = 61.0
        let aframe = CGRect(
            x: (bgView.dzy_w - awidth) / 2.0,
            y: (bgView.dzy_h - awidth) / 2.0,
            width: awidth, height: awidth
        )
        let aLayer = CAShapeLayer()
        aLayer.frame = aframe
        aLayer.path = UIBezierPath(ovalIn:
            CGRect(x: 0, y: 0, width: awidth, height: awidth)
            ).cgPath
        aLayer.lineWidth = 0.5
        aLayer.strokeColor = color.cgColor
        aLayer.fillColor = UIColor.clear.cgColor
        return aLayer
    }()
    
    /// 这个 layer 是不动的
    private lazy var cLayer: CAShapeLayer = {
        let cwidth: CGFloat = 60.0
        let cframe = CGRect(
            x: (bgView.dzy_w - cwidth) / 2.0,
            y: (bgView.dzy_h - cwidth) / 2.0,
            width: cwidth, height: cwidth
        )
        let cLayer = CAShapeLayer()
        cLayer.frame = cframe
        cLayer.path = UIBezierPath(ovalIn:
            CGRect(x: 0, y: 0, width: cwidth, height: cwidth)
            ).cgPath
        cLayer.lineWidth = 1
        cLayer.strokeColor = color.cgColor
        cLayer.fillColor = UIColor.clear.cgColor
        return cLayer
    }()
    // 圆圈动画
    private lazy var circleAniGroup: CAAnimationGroup = {
        //alpha
        let alpha = CABasicAnimation(keyPath: "opacity")
        alpha.fromValue = 1.0
        alpha.toValue = 0.6
        //scale
        let scale = CABasicAnimation(keyPath: "transform")
        let identity = CATransform3DIdentity
        scale.fromValue = NSValue(caTransform3D: CATransform3DScale(identity, 1.0, 1.0, 0))
        scale.toValue = NSValue(caTransform3D: CATransform3DScale(identity, 1.07, 1.07, 0))
        
        let group = CAAnimationGroup()
        group.animations = [alpha, scale]
        group.repeatCount = HUGE
        group.autoreverses = false
        group.duration = 1.0
        return group
    }()
}
