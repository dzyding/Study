//
//  FXRatingBar.swift
//  FXStarRatingTool
//
//  Created by Fxxx on 2017/12/4.
//  Copyright © 2017年 Aaron Feng. All rights reserved.
//

import UIKit

class NaRatingBar: UIView {
    
    private let yellowView = UIView()
    private var starWidth: CGFloat = 30.0
    
    var isAllowHalf = true
    var callBack:((Float) -> ())?

    

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)

        setupSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubview()
    }
    
    func setupSubview()
    {
        starWidth = frame.size.width / 5
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        setStarView(self, back: true)
        
        yellowView.backgroundColor = UIColor.clear
        yellowView.clipsToBounds = true
        yellowView.frame = CGRect.init(x: 0, y: 0, width: 0, height: frame.size.height)
        self.addSubview(yellowView)
        
        setStarView(yellowView, back: false)
    }
    
    func setStarView(_ view: UIView,back:Bool)
    {
        
        for i in 0..<5 {
            let imageview = UIImageView(image: UIImage(named: back ? "course_fitness_normal" : "course_fitness_fit"))
            imageview.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            imageview.center = CGPoint(x: starWidth/2 + CGFloat(i) * starWidth, y: frame.size.height/2)
            view.addSubview(imageview)
        }
    }
    
    func setStar(_ star:CGFloat)
    {
          yellowView.frame = CGRect.init(x: 0, y: 0, width: star * starWidth, height: self.bounds.size.height)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let item = touches.first
        let point = item?.location(in: self)
        yellowView.frame = CGRect.init(x: 0, y: 0, width: point!.x, height: self.bounds.size.height)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let item = touches.first
        let point = item?.location(in: self)
        var count = point!.x / starWidth
        count = count < 0 ? 0 : count
        count = count > 5 ? 5 :count
        if isAllowHalf {
            count = ceil(count / 0.5) * 0.5
        }else {
            count = ceil(count)
        }
        yellowView.frame = CGRect.init(x: 0, y: 0, width: count * starWidth, height: self.bounds.size.height)
        callBack?(Float(count))
        
    }

}
