//
//  UploadLoadingView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import LKAWaveCircleProgressBar

class UploadLoadingView: UIView
{
    var wcView:LKAWaveCircleProgressBar?
    var text: UILabel?
    
    var max = 0.0
    var current = 0.0
    
    var uploadIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLoading()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initLoading()
    {
        let mask = UIView(frame: self.bounds)
        mask.backgroundColor = UIColor.black
        mask.alpha = 0.5
        self.addSubview(mask)
        
        let wcView = LKAWaveCircleProgressBar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        wcView.center = self.center
        wcView.startWaveRollingAnimation()
        wcView.borderColor = YellowMainColor
        wcView.progress = 0
        wcView.progressAnimationDuration = 0.5
        wcView.progressTintColor = YellowMainColor.withAlphaComponent(0.5)
        self.addSubview(wcView)
        self.wcView = wcView
        
        let tx = UILabel()
        tx.textColor = UIColor.white
        tx.font = ToolClass.CustomBoldFont(30)
        self.addSubview(tx)
        tx.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        self.text = tx
    }
    
    func setProgress(_ add: Double) -> Int
    {
        current = current + add
        current = current > max ? max : current
        let progress = String.init(format: "%.0f", current * 100/max)
        self.text?.text = progress + "%"
            
        self.wcView?.setProgress( Float(self.current/self.max), animated: true)
        
        if add == 1
        {
            self.uploadIndex += 1
        }
        
        return self.uploadIndex == Int(max) ? 1 : 0
    }
    

    
    class func showUploadLoadingView() ->UploadLoadingView
    {
        let loadingview = UploadLoadingView(frame: ScreenBounds)
        UIApplication.shared.keyWindow?.addSubview(loadingview)
        return loadingview
    }
}
