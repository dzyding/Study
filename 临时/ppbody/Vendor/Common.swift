//
//  Common.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation


let ScreenBounds = CGRect(x: 0, y: 0, width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height))

let ScreenWidth = min(ScreenBounds.width,ScreenBounds.height) 

let ScreenHeight = max(ScreenBounds.width,ScreenBounds.height)

let ScreenScale = UIScreen.main.scale

let ColorLine = UIColor.ColorHex("#3E3E3E")

let BackgroundColor = UIColor.ColorHex("#232327")

let CardColor = UIColor.ColorHex("#333237")

let YellowMainColor = UIColor.ColorHex("#F8E71C")

let BlueLineColor = UIColor.ColorHex("#3afdfe")

let TextMainColor = UIColor.ColorHex("#FFFFFF")

let Text1Color = UIColor.ColorHex("#999999")


let LINE_HEIGHT = ScreenHeight > 500 ? 0.5 : 1

let IS_IPHONEX = isiPhoneXScreen() ? true : false

let SafeTop = isiPhoneXScreen() ? 44 : 0

let SafeBottom = isiPhoneXScreen() ? 34 : 0

let StatusBarHeight = isiPhoneXScreen() ? 20 : 43

let OfficialColor = UIColor.ColorHex("#ff4e50")

let DefaultHeader = UIImage(named: "person_head_default")

let DefaultPic = UIImage(named: "default_image_house")

let VideoDuration = getDurationFromUserInfo()


//是否需要进行教练提示
var isFistCoachTip = false

var TopicTag:String?

var PushTag:String?

func isiPhoneXScreen() -> Bool {
    var iPhoneXSeries = false
    if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone
    {
        return iPhoneXSeries
    }
    
    if #available(iOS 11.0, *)
    {
        let mainWindow = UIApplication.shared.delegate?.window
        
        if mainWindow!!.safeAreaInsets.bottom > 0
        {
            iPhoneXSeries = true
        }
    }
    
   
    return iPhoneXSeries
}

//获取视频的最大时长
func getDurationFromUserInfo() -> Int
{
    let uid = DataManager.userAuth()
    let userId = ToolClass.decryptUserId(uid)
    
    if DataManager.isCoach() || userId == 1000
    {
        return 90
    }else{
        if userId == 1004
        {
            return 300
        }else{
            return 15
        }
    }
    
}

// 自适应屏幕宽度
func FIT_SCREEN_WIDTH(_ size: CGFloat) -> CGFloat {
    return size * ScreenWidth / 375.0
}
// 自适应屏幕高度
func FIT_SCREEN_HEIGHT(_ size: CGFloat) -> CGFloat {
    return size * ScreenHeight / 667.0
}
// 自适应屏幕字体大小
func AUTO_FONT(_ size: CGFloat) -> UIFont {
    let autoSize = size * ScreenWidth / 375.0
    return ToolClass.CustomFont(autoSize)
}

let AliyunOutputVideoSize = CGSize(width: 720, height: 1280)
