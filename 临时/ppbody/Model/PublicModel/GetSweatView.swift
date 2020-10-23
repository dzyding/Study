//
//  GetSweatView.swift
//  PPBody
//
//  Created by edz on 2018/12/14.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class GetSweatView: UIView {
    
    var title: String
    
    var width: CGFloat
    
    var height: CGFloat
    
    init(_ title: String) {
        self.title = title
        let size = dzy_strSize(str: title,
                                 font: UIFont.boldSystemFont(ofSize: 15),
                                 width: ScreenWidth - 200)
        self.width = size.width + 170
        self.height = size.height > 40 ? 50 : 40
        let frame = CGRect(x: -ScreenWidth, y: 200, width: width, height: height)
        super.init(frame: frame)
        backgroundColor = .clear
        uiStep()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func uiStep() {
        let bgIV = UIImageView(image: UIImage(named: "get_sweat_bg"))
        addSubview(bgIV)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5.0
        let attStr = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.paragraphStyle : style
            ])
        
        let titleLB = UILabel(frame: .zero)
        titleLB.attributedText = attStr
//        titleLB.numberOfLines = 0
        addSubview(titleLB)
        
        let sweatIV = UIImageView(image: UIImage(named: "get_sweat_icon"))
        sweatIV.contentMode = .scaleAspectFit
        addSubview(sweatIV)
        
        titleLB.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(self.width)
            make.height.lessThanOrEqualTo(40)
        }
        
        sweatIV.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLB)
            make.left.equalTo(titleLB.snp.right)
            make.height.width.equalTo(20)
        }
        
        bgIV.snp.makeConstraints { (make) in
            make.width.equalTo(titleLB).offset(100)
            make.height.equalTo(67)
            make.centerY.equalTo(titleLB)
            make.centerX.equalTo(titleLB).offset(20)
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        transform = transform.translatedBy(x: ScreenWidth * 2, y: 0)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        UIView.animateKeyframes(withDuration: 10, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.transform = self.transform.translatedBy(x: -ScreenWidth, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}
