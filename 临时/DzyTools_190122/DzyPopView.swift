//
//  DzyPopView.swift
//  LengLian
//
//  Created by dzy_PC on 16/6/30.
//  Copyright © 2016年 LengMarlon. All rights reserved.
//

import UIKit

enum DzyPopType: Int {
    case POP_top
    case POP_bottom
    case POP_center
    ///中偏上 (100)
    case POP_center_above
}

class DzyPopView: UIView {
    ///半透明背景
    var popView:UIView!
    
    var sourceView:UIView?
    
    var type:DzyPopType
    
    var originFrame:CGRect = .zero
    
    init(_ animateType:DzyPopType) {
        type = animateType
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .clear
        setPopView()
    }
    
    init(_ animateType:DzyPopType, viewBlock:()->(UIView)) {
        type = animateType
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .clear
        setPopView()
        sourceView = viewBlock()
        setSource(animateType)
    }
    
    func updateSourceView(_ v: UIView) {
        if let sourceView = sourceView {
            sourceView.removeFromSuperview()
        }
        sourceView = v
        setSource(type)
    }
    
    func setPopView() {
        popView = UIView(frame: UIScreen.main.bounds)
        popView.backgroundColor = .black
        popView.isUserInteractionEnabled = true
        addSubview(popView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(backGroundClick))
        popView.addGestureRecognizer(tap)
    }
    
    func show(_ view: UIView? = nil) {
        alpha = 1
        if let view = view {
            view.addSubview(self)
        }else {
            KEY_WINDOW?.addSubview(self)
        }
    }
    
    func hide() {
        switch type {
        case .POP_center,.POP_center_above:
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
            }, completion: { (finished:Bool) in
                self.removeFromSuperview()
            }) 
        case .POP_bottom: fallthrough
        default:
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
                self.sourceView?.transform = .identity
            }, completion: { (finished:Bool) in
                self.removeFromSuperview()
            }) 
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let sourceView = sourceView else {return}
        switch type {
        case .POP_center,.POP_center_above:
            popView.alpha = 0
            sourceView.transform = sourceView.transform.scaledBy(x: 0.1, y: 0.1)
        case .POP_bottom:
            sourceView.frame = originFrame
            popView.alpha = 0
        default:
            popView.alpha = 0
        }
    }
    
    override func didMoveToSuperview() {
        guard let sourceView = sourceView else {return}
        switch type {
        case .POP_center,.POP_center_above:
            UIView.animate(withDuration: 0.2, animations: {
                self.popView.alpha = 0.7
            })
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
                sourceView.transform = .identity
            }, completion: nil )
        case .POP_bottom:
            UIView.animate(withDuration: 0.2, animations: {
                self.popView.alpha = 0.7
            })
            UIView.animate(withDuration: 0.4, animations: {
                sourceView.transform = sourceView.transform.translatedBy(x: 0, y: -sourceView.frame.size.height)
            })
        default:
            UIView.animate(withDuration: 0.2, animations: {
                self.popView.alpha = 0.7
            })
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations: {
                sourceView.transform = sourceView.transform.translatedBy(x: 0, y: sourceView.frame.size.height)
            }, completion:nil )
        }
    }

    ///设置内容
    func setSource(_ type:DzyPopType) {
        guard let sourceView = sourceView else {return}
        addSubview(sourceView)
        switch type {
        case .POP_center:
            sourceView.center = center
        case .POP_center_above:
            var p = center
            p.y -= 50
            sourceView.center = p
        case .POP_bottom:
            var f = sourceView.frame
            f.origin.x = (Screen_W - f.size.width)/2.0
            f.origin.y = Screen_H
            sourceView.frame = f
        default:
            var f = sourceView.frame
            f.origin.x = (Screen_W - f.size.width)/2.0
            f.origin.y = -f.size.height
            sourceView.frame = f
        }
        originFrame = sourceView.frame
    }

    ///点击背景消失
    @objc func backGroundClick() {
        hide()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        dzy_log("deinit")
    }
}
