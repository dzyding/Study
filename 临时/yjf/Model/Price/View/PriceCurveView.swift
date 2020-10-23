//
//  PriceCurveView.swift
//  YJF
//
//  Created by edz on 2019/8/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum CurveType {
    /// 曲线
    case curve
    /// 直线
    case normal
}

class PriceCurveView: UIView {
    /// 需要清除的 view
    private let cleanTag = 777
    // scrollView 左右的边距
    private let leftP: CGFloat = 25.0
    
    private let rightP: CGFloat = 25.0
    // key 到底部的距离
    private let keyBottom: CGFloat = 10.0
    // 横向的左间距
    private let xS: CGFloat = 63.0
    // 横向的右间距
    private let xE: CGFloat = 19.0
    // 纵向的上边距
    private let yS: CGFloat = 30.0
    // 纵向的下边距
    private let yE: CGFloat = 35.0
    // 总高度
    private var height: CGFloat {
        return frame.size.height - (yS + yE)
    }
    // 总宽对
    private var width: CGFloat {
        return frame.size.width - (xS + xE)
    }
    
    //横向平分值
    private var x: CGFloat {
        return (width - leftP - rightP) / 4.0
    }
    // 纵向平分值
    private var y: CGFloat {
        return height / 3.0
    }
    
    private lazy var scrollView = UIScrollView()
    
    private weak var slayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    private func initUI() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.tag = 99
        addSubview(scrollView)
        
        (0...3).forEach { (i) in
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.sizeToFit()
            label.tag = 100 + i
            label.textColor = dzy_HexColor(0xa3a3a3)
            label.textAlignment = .center
            addSubview(label)
            
            let bottom = yE + CGFloat(i) * y - label.frame.height / 2.0
            label.snp.makeConstraints({ (make) in
                make.left.equalTo(8)
                make.bottom.equalTo(-bottom)
            })
            
//            let line = UIView()
//            line.backgroundColor = .lightGray
//            scrollView.addSubview(line)
//
//            let lineTop = frame.height - bottom - label.frame.height / 2.0
//            line.snp.makeConstraints({ (make) in
//                make.top.equalTo(lineTop)
//                make.left.equalTo(leftP)
//                make.height.equalTo(1)
//                make.width.equalTo(scrollView.dzy_cSizeW - leftP - rightP)
//            })
        }
    }
    
    private func cleanSubViews() {
        var index = 0
        slayer?.removeFromSuperlayer()
        while index < scrollView.subviews.count {
            let sv = scrollView.subviews[index]
            if sv.tag == cleanTag {
                sv.removeFromSuperview()
            }else {
                index += 1
            }
        }
    }
    
    private func addDotWith(_ point: CGPoint) {
        let frame = CGRect(x: 0, y: 0, width: 6, height: 6)
        
        let path = UIBezierPath(ovalIn: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 1
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.frame = frame
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = MainColor.cgColor
        
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.white
        view.tag = cleanTag
        view.layer.addSublayer(shapeLayer)
        scrollView.addSubview(view)
        view.center = point
    }
    
    //swiftlint:disable:next function_body_length
    func updateUI(_ values: [Double], keys: [String], type: CurveType) {
        cleanSubViews()
        // 更改 scrollView 的相关设置
        let sFrame = CGRect(x: xS, y: 0, width: width, height: frame.height)
        let num = (keys.count - 1 < 4) ? 4 : (keys.count - 1)
        let cWidth = x * CGFloat(num) + leftP + rightP
        scrollView.frame = sFrame
        scrollView.contentSize = CGSize(width: cWidth, height: frame.height)
        
        // 更改 values 相关 label 的数据
        guard let maxNum = values.max() else {return}
//        if maxNum % 3 != 0 {
//            maxNum = ((maxNum / 3) + 1) * 3
//        }
        
        (0...3).forEach { (i) in
            (viewWithTag(100 + i) as? UILabel).flatMap({
                $0.text = String(
                    format: "%.2lf万", Double(i) * maxNum / 3.0
                )
            })
        }

        var lbH: CGFloat = 0
        keys.enumerated().forEach { (i, str) in
            let label = UILabel()
            label.text = str
            label.font = dzy_Font(12)
            label.sizeToFit()
            label.textColor = dzy_HexColor(0xa3a3a3)
            label.tag = cleanTag
            scrollView.addSubview(label)
            
            lbH = label.frame.height / 2.0
            let top = frame.height - keyBottom - label.frame.height
            let left = leftP + CGFloat(i) * x - label.frame.width / 2.0
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(top)
                make.left.equalTo(left)
            })
        }
        
        let path = UIBezierPath()
        let points = values.enumerated().map { (i, num) -> CGPoint in
            let px = leftP + CGFloat(i) * x
            var py = frame.height - yE - lbH
            if maxNum != 0 {
                py -= CGFloat(num) / CGFloat(maxNum) * height
            }
            return CGPoint(x: px, y: py)
        }
        if points.count == 1 {
            path.move(to: points[0])
            path.addLine(to: points[0])
        }else {
            (0..<points.count - 1).forEach { (i) in
                let startP = points[i]
                let endP = points[i + 1]
                path.move(to: startP)
                switch type {
                case .curve:
                    let control1 = CGPoint(x: (endP.x - startP.x) / 2.0 + startP.x, y: startP.y)
                    let control2 = CGPoint(x: (endP.x - startP.x) / 2.0 + startP.x, y: endP.y)
                    path.addCurve(to: endP, controlPoint1: control1, controlPoint2: control2)
                case .normal:
                    path.addLine(to: endP)
                }
            }
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.frame = bounds
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = MainColor.cgColor
        scrollView.layer.addSublayer(shapeLayer)
        self.slayer = shapeLayer
        
        // 这个必须放最后，不然会被曲线挡住
        points.forEach { (point) in
            addDotWith(point)
        }
    }
}
