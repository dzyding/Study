//
//  HomePopView.swift
//  YJF
//
//  Created by edz on 2019/4/25.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HomePopViewDelegate {
    func popViewDidDismiss(_ popView: HomePopView)
}

class HomePopView: UIView {
    
    weak var delegate: HomePopViewDelegate?
    
    private weak var sourceView: UIView?
    /// sourceView 的原始frame，用来做动画
    private var svOriginFrame: CGRect = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        let bgView = UIView(frame: bounds)
        bgView.backgroundColor = RGBA(r: 51.0, g: 51.0, b: 51.0, a: 0.7)
        bgView.isUserInteractionEnabled = true
        addSubview(bgView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        bgView.addGestureRecognizer(tap)
    }
    
    func updateSourceView(_ sourceV: UIView) {
        if sourceView?.superview != nil {
            sourceView?.removeFromSuperview()
        }
        sourceV.clipsToBounds = true
        addSubview(sourceV)
        self.svOriginFrame = sourceV.frame
        self.sourceView = sourceV
    }
    
    func show(_ view: UIView) {
        view.addSubview(self)
    }
    
    @objc func dismiss() {
        delegate?.popViewDidDismiss(self)
        removeFromSuperview()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        var frame = svOriginFrame
        frame.size.height = 1
        sourceView?.frame = frame
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 0.25) {
            self.sourceView?.frame = self.svOriginFrame
        }
    }
}
