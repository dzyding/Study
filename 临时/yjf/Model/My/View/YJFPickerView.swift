//
//  YJFPickerView.swift
//  190418_渐变
//
//  Created by edz on 2019/4/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol YJFPickerViewDelegate {
    func pickerView(_ pickerView: YJFPickerView, didSelect data: [String : Any], index: Int)
    func didDismiss(_ pickerView: YJFPickerView)
}

class YJFPickerView: UIView {
    
    weak var delegate: YJFPickerViewDelegate?
    
    private var cornerH: CGFloat = 10.0
    
    private var sourceH: CGFloat = 150.0
    
    private var width = UIScreen.main.bounds.size.width
    
    private var padding: CGFloat = 16.0
    
    private lazy var sourceView: YJFPickerSourceView = {
        let v = YJFPickerSourceView(frame: CGRect(
            x: 0, y: 0,
            width: width - padding * 2, height: sourceH - cornerH)
        )
        v.handler = { [unowned self] (index, data) in
            self.dismiss()
            self.delegate?.pickerView(self, didSelect: data, index: index)
        }
        return v
    }()
    
    private weak var bgView: YJFPickerBgView?
    
    var isEmpty: Bool {
        return sourceView.datas.isEmpty
    }

    init() {
        super.init(frame: UIScreen.main.bounds)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        let tapView = UIView(frame: bounds)
        tapView.backgroundColor = .clear
        tapView.isUserInteractionEnabled = true
        addSubview(tapView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapView.addGestureRecognizer(tap)
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        delegate?.didDismiss(self)
        dismiss()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        var sframe = sourceView.frame
        sframe.size.height = 0
        sourceView.frame = sframe
        bgView?.alpha = 0
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        UIView.animate(withDuration: 0.25) {
            var sframe = self.sourceView.frame
            sframe.size.height = self.sourceH
            self.sourceView.frame = sframe
            self.bgView?.alpha = 1
        }
    }
    
    func updateUI(_ datas:[[String : Any]], point: CGPoint, type: YJFPickerSourceType) {
        if bgView != nil {
            bgView?.removeFromSuperview()
        }
        sourceH = CGFloat(datas.count) * 45.0 + cornerH
        sourceH = min(sourceH, cornerH + 45.0 * 4.5)
        let pickerBg = YJFPickerBgView(frame: CGRect(
            x: padding,
            y: point.y + cornerH,
            width: width - padding * 2.0,
            height: sourceH)
        )
        pickerBg.pointX = point.x - padding
        pickerBg.backgroundColor = .clear
        pickerBg.layer.shadowColor = UIColor.black.cgColor
        pickerBg.layer.shadowOffset = CGSize(width: 0, height: 0)
        pickerBg.layer.shadowRadius = 3
        pickerBg.layer.shadowOpacity = 0.3
        insertSubview(pickerBg, at: 1)
        self.bgView = pickerBg
        
        if sourceView.superview == nil {
            addSubview(sourceView)
        }
        let frame = CGRect(
            x: padding,
            y: pickerBg.frame.minY + cornerH,
            width: pickerBg.frame.width,
            height: sourceH - cornerH
        )
        sourceView.updateFrame(frame)
        sourceView.reloadData(datas, type: type)
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func dismiss() {
        removeFromSuperview()
    }
}
