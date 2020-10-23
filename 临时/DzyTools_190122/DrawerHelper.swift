//
//  DrawerHelper.swift
//  Swift学习
//
//  Created by dzy_PC on 17/7/13.
//  Copyright © 2017年 dzy_PC. All rights reserved.
//

import UIKit

class DrawerHelper: NSObject {
    fileprivate var startX: CGFloat = 0
    
    fileprivate var view: UIView!
    
    fileprivate var originalFrame: CGRect = .zero
    
    fileprivate var hideHandler: (()->())?
    
    init(_ view: UIView, handler: (()->())?) {
        super.init()
        self.view = view
        self.hideHandler = handler
        self.originalFrame = view.frame
        setPanGesture()
    }
    
    func show(inView: UIView? = nil) {
        view.frame = originalFrame
        if inView == nil {
            KEY_WINDOW?.addSubview(view)
        }else {
            inView?.addSubview(view)
        }
    }
    
    func hideAction() {
        hideHandler?()
    }
    
    fileprivate func setPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
    }
    
    @objc func pan(_ pan:UIPanGestureRecognizer) {
        let width = view.dzy_w;
        switch (pan.state) {
        case .began:
            startX = view.dzy_x
            view.isUserInteractionEnabled = false
        case .changed:
            let now = pan.translation(in: pan.view)
            if (startX <= Screen_W - width && now.x <= 0) {
                return
            }else {
                let now_x = CGRect(x: startX + now.x, y: 0, width: width, height: view.dzy_h)
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.frame = now_x
                })
            }
        case .ended: fallthrough
        case .failed:
            let last_x = view.dzy_x
            view.isUserInteractionEnabled = true
            if (last_x >= (view.dzy_w - width/2.0)) {
                hideAction()
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: Screen_W - width, y: 0, width: width, height: Screen_H)
                })
            }
        default:
            break
        }
    }
}
