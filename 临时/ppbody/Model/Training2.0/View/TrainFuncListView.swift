//
//  TrainFuncListView.swift
//  PPBody
//
//  Created by edz on 2019/12/20.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainFuncListView: UIView, InitFromNibEnable {

    @IBOutlet weak var stackView: UIStackView!
    // 5 0
    @IBOutlet weak var topLC: NSLayoutConstraint!
    // 0 5
    @IBOutlet weak var bottomLC: NSLayoutConstraint!
    
    @IBOutlet weak var bgIV: UIImageView!
    
    func initUI(_ titleArr: [(title: String, imgName: String)],
                handlerArr: [()->()])
    {
        assert(titleArr.count == handlerArr.count)
        self.frame = CGRect(x: 0,
                            y: 0,
                            width: 75,
                            height: 45 * titleArr.count + 5)
        titleArr.enumerated().forEach { (index, title) in
            let view = TrainFuncBaseView.initFromNib()
            view.initUI(title, handler: handlerArr[index]) { [weak self] in
                self?.dismiss()
            }
            stackView.addArrangedSubview(view)
        }
    }
    
    func show(in view: UIView, sframe: CGRect) {
        coverView.frame = view.bounds
        view.addSubview(coverView)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        if (sframe.maxY + frame.height + 5.0) > view.frame.height {
            let point = CGPoint(x: sframe.midX - 10,
                                y: sframe.minY - 5)
            x = point.x - dzy_w / 2.0
            y = point.y - frame.height - 5
            topLC.constant = 0
            bottomLC.constant = 5
            bgIV.image = UIImage(named: "train_action_bg_bottom")
        }else {
            let point = CGPoint(x: sframe.midX - 10,
                                y: sframe.maxY + 5)
            x = point.x - dzy_w / 2.0
            y = point.y + 5
            topLC.constant = 5
            bottomLC.constant = 0
            bgIV.image = UIImage(named: "train_action_bg_top")
        }
        frame = CGRect(x: x,
                       y: y,
                       width: frame.width,
                       height: frame.height)
        view.addSubview(self)
    }
    
    @objc private func dismiss() {
        coverView.removeFromSuperview()
        removeFromSuperview()
    }
    
//    MARK: - 懒加载
    private lazy var coverView: UIView = {
        let view = UIView(frame: ScreenBounds)
        view.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self,
                                action: #selector(dismiss))
        view.addGestureRecognizer(tap)
        return view
    }()
}
