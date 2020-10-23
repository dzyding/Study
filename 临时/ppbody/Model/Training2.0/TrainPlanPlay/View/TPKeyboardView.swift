//
//  TPKeyboardView.swift
//  PPBody
//
//  Created by edz on 2020/1/8.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TPKeyboardBtn: UIButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    fileprivate func initUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let view = LinearGradientView(
                self.bounds,
                startColor: RGBA(r: 43, g: 43, b: 43, a: 1),
                finishColor: RGBA(r: 33, g: 33, b: 33, a: 1))
            view.isUserInteractionEnabled = false
            if let imgView = self.imageView {
                self.insertSubview(view, belowSubview: imgView)
            }else {
                self.addSubview(view)
            }
        }
    }
}

enum TPKeyboardActionType: Int {
    case dot = 10// 点
    case delete // 删除
    case add
    case reduce
    case addGroup
    case next
}

protocol TPKeyboardViewDelegate: class {
    func kb(_ kb: TPKeyboardView, didSelectNum num: Int)
    func kb(_ kb: TPKeyboardView,
            didSelectAction action: TPKeyboardActionType)
}

class TPKeyboardView: UIView, InitFromNibEnable {
    
    weak var delegate: TPKeyboardViewDelegate?
    
    weak var tf: UITextField?
 
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnAction(_ sender: TPKeyboardBtn) {
        if let type = TPKeyboardActionType(rawValue: sender.tag) {
            delegate?.kb(self, didSelectAction: type)
        }else {
            delegate?.kb(self, didSelectNum: sender.tag)
        }
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        TPKeyboardActionType(rawValue: sender.tag).flatMap({
            delegate?.kb(self, didSelectAction: $0)
        })
    }
}
