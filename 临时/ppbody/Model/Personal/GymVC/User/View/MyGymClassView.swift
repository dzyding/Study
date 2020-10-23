//
//  MyGymClassView.swift
//  PPBody
//
//  Created by edz on 2019/4/16.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol MyGymClassViewDelegate {
    func gymClass(_ gymClassView: MyGymClassView, didSelectedClass data: [String : Any])
    func gymClass(_ gymClassView: MyGymClassView, didSelectedMoreBtn btn: UIButton)
}

class MyGymClassView: UIView {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var heightLC: NSLayoutConstraint!
    
    private var mySubViews: [MyGymClassBaseView] = []
    
    weak var delegate: MyGymClassViewDelegate?
    
    func updateViews(_ list: [[String : Any]]) {
        let width = (ScreenWidth - 30.0 - 42.0) / 2.0
        let height = width - 5.0
        if list.count == 0 {
            let imgView = UIImageView(image: UIImage(named: "gym_no_class"))
            imgView.contentMode = .scaleAspectFit
            bgView.addSubview(imgView)
            
            imgView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLB.snp.bottom).offset(23.0)
                make.left.right.equalTo(0)
                make.height.equalTo(height)
            }
            return
        }
        let handler: (([String : Any])->()) = { [unowned self] classData in
            self.delegate?.gymClass(self, didSelectedClass: classData)
        }
        if list.count < mySubViews.count {
            (list.count..<mySubViews.count).forEach { (index) in
                mySubViews[index].removeFromSuperview()
                mySubViews.remove(at: index)
            }
        }
        list.enumerated().forEach { (index, dic) in
            if index < mySubViews.count {
                let view = mySubViews[index]
                view.handler = handler
                view.updateViews(dic)
            }else {
                let row = index / 2
                let col = index % 2
                let view = MyGymClassBaseView
                    .initFromNib(MyGymClassBaseView.self)
                bgView.addSubview(view)
                view.handler = handler
                view.updateViews(dic)
                mySubViews.append(view)
                
                let top = 23.0 + CGFloat(row) * (height + 10.0)
                let left = 16 + CGFloat(col) * (width + 10.0)
                view.snp.makeConstraints({ (make) in
                    make.top.equalTo(titleLB.snp.bottom).offset(top)
                    make.left.equalTo(left)
                    make.height.equalTo(height)
                    make.width.equalTo(width)
                })
            }
        }
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        delegate?.gymClass(self, didSelectedMoreBtn: sender)
    }
}
