//
//  NavBarHidden.swift
//  YiXiu
//
//  Created by Nathan_he on 16/9/22.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit

class NavBarHidden :BaseVC
{
    
    struct NaHidenControlOptions : OptionSet {
        let rawValue: Int
        
        static let left  = NaHidenControlOptions(rawValue: 1 << 0)
        static let title = NaHidenControlOptions(rawValue: 1 << 1)
        static let right  = NaHidenControlOptions(rawValue: 1 << 2)
    }
    

    
    private let hy_scrolOffsetY : CGFloat = 600.0
    
    private let key : String = "keyScrollView"
    
    private let navBarBackgroundImageKey : String = "navBarBackgroundImage";
    
    private let scrolOffsetYKey : String = "offsetY";
    
    private let hy_hidenControlOptionsKey : String = "hy_hidenControlOptions";
    
    private var option : NaHidenControlOptions?
    
    // MARK: 通过运行时动态添加存储属性
    private  var keyScrollView : UIScrollView!
    
    private  var navBarBackgroundImage : UIImage?

    private var scrolOffsetY : CGFloat!

    private var hy_hidenControlOptions : NaHidenControlOptions!

    public func setKeyScrollView(_ keyScrollView:UIScrollView , _ scrolOffsetY:CGFloat , _ options:NaHidenControlOptions)
    {
        self.keyScrollView = keyScrollView;
        self.hy_hidenControlOptions = options;
        self.scrolOffsetY = scrolOffsetY;
        
        self.keyScrollView.addObserver((self as AnyObject) as! NSObject, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        
        
    }
    
     var alpha : CGFloat = 0;
     var offsetY : CGFloat = 0;
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
//        let offsetY : CGFloat = self.doDeviceVersion()<=5 ? hy_scrolOffsetY : self.scrolOffsetY
        
        guard self == self.navigationController?.children.last else {
            return
        }
        
        let offsetY : CGFloat = self.scrolOffsetY
        let point : CGPoint = self.keyScrollView.contentOffset
        alpha = point.y/offsetY
                
        alpha = (alpha <= 0) ? 0 : alpha
        alpha = (alpha >= 1) ? 1 : alpha
        
        //设置导航条上的标签是否跟着透明
        self.navigationItem.leftBarButtonItem?.customView?.alpha = (self.hy_hidenControlOptions.contains(.left)) ? alpha : 1;
        self.navigationItem.titleView?.alpha = (self.hy_hidenControlOptions.contains(.title)) ? alpha : 1;
//        self.navigationItem.rightBarButtonItem?.customView?.alpha = (self.hy_hidenControlOptions.contains(.right)) ? alpha : 1;
        
        self.navigationController?.navigationBar.subviews.first?.alpha = alpha
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.subviews.first?.alpha = alpha
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.subviews.first?.alpha = 1
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.subviews.first?.alpha = 1
    }
    
    deinit {
        self.keyScrollView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }
    
    
     func doDevicePlatform() -> String
    {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    
     func doDeviceVersion() -> Int
    {
        let arr = doDevicePlatform().components(separatedBy: ",")
        var deviceVersion : Int = 0
        if (arr.first?.contains("iPhone"))!
        {
            
            let str = arr.first!
            deviceVersion = Int(str[str.index(str.endIndex, offsetBy: -1)..<str.endIndex])!
        }
        
        return deviceVersion
    }
    
    
}
