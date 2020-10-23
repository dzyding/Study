//
//  ShowInViewProtocol.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

protocol ShowInViewProtocol where Self: UIView {
    var originFrame: CGRect {get set}
    var isShow: Bool {get set}
    /// 展示
    func show(in view: UIView, y: CGFloat)
    /// 隐藏
    func dismiss()
    /// 缩小
    func scale()
    /// 还原
    func original()
    /// 没有动画的隐藏
    func remove()
}

extension ShowInViewProtocol {
    func show(in view: UIView, y: CGFloat) {
        isShow = true
        alpha = 1
        
        // 背景的模糊视图
        var bounds = view.bounds
        bounds.origin.y = y
        let bgView = Show_ClickView(bounds) { [weak self] in
            self?.dismiss()
        }
        bgView.backgroundColor = RGBA(r: 15.0, g: 15.0, b: 15.0, a: 0.7)
        bgView.tag = 789
        view.addSubview(bgView)
        
        var temp = frame
        temp.origin.y = y
        frame = temp
        view.addSubview(self)
    }
    
    func dismiss() {
        let view = superview?.viewWithTag(789)
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            view?.alpha = 0
        }) { (_) in
            self.isShow = false
            view?.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    func remove() {
        isShow = false
        superview?.viewWithTag(789).flatMap({
            $0.removeFromSuperview()
        })
        removeFromSuperview()
    }
    
    func scale() {
        originFrame = frame
        var temp = frame
        temp.size.height = 1
        frame = temp
    }
    
    func original() {
        UIView.animate(withDuration: 0.5) {
            self.frame = self.originFrame
        }
    }
}

private class Show_ClickView: UIView {
    
    let handler: ()->()
    
    init(_ frame: CGRect, handler: @escaping ()->()) {
        self.handler = handler
        super.init(frame: frame)
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(bgClickAction))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func bgClickAction() {
        handler()
    }
}
