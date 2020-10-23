//
//  DzyStarView.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/9/22.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

class DzyStarView: UIView {
    //数量
    fileprivate var num: Int
    //普片名字
    fileprivate var normal: String
    //选中的名字
    fileprivate var selected: String
    //按钮集合
    fileprivate var btns: [UIButton] = []
    
    var handler: ((Int) -> ())?
    
    //间隔
    var padding: CGFloat = UI_W(5)

    init(_ num: Int = 5, normal: String, selected: String, frame: CGRect) {
        self.num = num
        self.normal = normal
        self.selected = selected
        super.init(frame: frame)
        initStars()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func action(_ btn: UIButton) {
        updateViews(btn.tag)
        handler?(btn.tag)
    }
    
    func updateViews(_ x: Int) {
        if x < 0 {
            btns.forEach({$0.isSelected = false})
        }else {
            (0...x).forEach { (index) in
                btns[index].isSelected = true
            }
            ((x + 1)..<num).forEach { (index) in
                btns[index].isSelected = false
            }
        }
        
    }
    
    func initStars() {
        (0..<num).forEach({ index in
            let star = UIButton(type: .custom)
            star.setImage(UIImage(named: normal), for: .normal)
            star.setImage(UIImage(named: selected), for: .selected)
            star.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
            star.tag = index
            
            let num = CGFloat(self.num)
            let h = dzy_h
            let w = (dzy_w - num * padding) / num
            let x = padding + CGFloat(index) * (w + padding)
            star.frame = CGRect(x: x, y: 0, width: w, height: h)
            
            addSubview(star)
            btns.append(star)
        })
    }
}
