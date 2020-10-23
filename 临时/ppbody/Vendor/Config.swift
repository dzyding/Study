//
//  Config.swift
//  ZAJA_Agent
//
//  Created by Nathan_he on 2017/1/12.
//  Copyright © 2017年 Nathan_he. All rights reserved.
//

import Foundation

class Config {
    static let Notify_ChangeStatisticsData = Notification.Name("Notify_ChangeStatisticsData")
    //训练数据添加通知
    static let Notify_AddTrainingData =  Notification.Name("Notify_AddTrainingData")
    //训练数据编辑通知
    static let Notify_EditTrainingData =  Notification.Name("Notify_EditTrainingData")
    //自定义计划的变动通知
    static let Notify_EditMotionPlanData = Notification.Name("Notify_EditMotionPlanData")
    //修改头像
    static let Notify_ChangeHead = Notification.Name("Notify_ChangeHead")
    //私教销课
    static let Notify_ReduceCourse = Notification.Name("Notify_ReduceCourse")
    //添加动作
    static let Notify_AddMotionData = Notification.Name("Notify_AddMotionData")
    //添加课程
    static let Notify_AddCourseData = Notification.Name("Notify_AddCourseData")
    //教练审核通过
    static let Notify_CoachReviewSuccess = Notification.Name("Notify_CoachReviewSuccess")
    //学员切换
    static let Notify_ChangeMember = Notification.Name("Notify_ChangeMember")
    //支付宝登录通知
    static let Notify_AlipayLogin = Notification.Name("Notify_AlipayLogin")
    //成为学员支付成功通知
    static let Notify_PaySuccess = Notification.Name("Notify_PaySuccess")
    //解除学员教练关系
    static let Notify_ExitMember = Notification.Name("Notify_ExitMember")
    //聊天的IM消息通知
    static let Notify_MessageForIM = Notification.Name("Notify_MessageForIM")
    //清除已读消息
    static let Notify_ClearMessage = Notification.Name("Notify_ClearMessage")
    //体态修改发送通知更新
    static let Notify_BodyDataChange = Notification.Name("Nofity_BodyDataChange")
    //成为教练的学员页面更新通知
    static let Notify_BeCoachMember = Notification.Name("Nofity_BeCoachMember")
    //关注好友的通知消息
    static let Notify_AttentionPersonal = Notification.Name("Notify_AttentionPersonal")
    //发布话题通知提醒
    static let Notify_PublicTopic = Notification.Name("Notify_PublicTopic")
    ///更新订单界面
    static let Notify_RefreshLocationOrder = Notification.Name("RefreshLocationOrder")
    ///更新地址列表界面
    static let Notify_RefreshAddressList = Notification.Name("RefreshAddressList")
    ///更新当前城市
    static let Notify_RefreshLocationCity = Notification.Name("RefreshLocationCity")
    /// 应用进入前台
    static let Notify_DidBecomeActive = Notification.Name("DidBecomeActive")
    /// 用户编辑完当前的周计划
    static let Notify_UserEditWeekMotionPlan = Notification.Name( "UserEditWeekMotionPlan")
    /// 用户添加了训练计划
    static let Notify_UserAddMotionPlan = Notification.Name("UserAddMotionPlan")

    static let ReduceCompleteKey = "reduceComplete"
    
    //支付宝登录
    static let Alipay_login_authInfo = "apiname=com.alipay.account.auth&app_id=2018061360401251&app_name=ppbody&auth_type=AUTHACCOUNT&biz_type=openservice&method=alipay.open.auth.sdk.code.get&pid=2088131544255798&product_id=APP_FAST_LOGIN&scope=kuaijie&target_id=20141225ppbody&sign=GAsUtumlteMbcQd%2B%2BgCWcREBUS3B2TK74vkkFMqwrEphsapl%2BZYclImeihLlhnCnwJ7lQ8MzVZZ7fDDjBUugN8U0uVJNmy6Rvkvnf8ufdmk5cewaAOgGCwU0W%2FFNmpfI4pAdOVRfaGXmh4icaiHqInrdtvQouV%2BaPo46cLZYlDyzzt3YbaV3nwz2ekzdfItzTJes1k1UoEX4Py2Tr4Daco18GhHeJfEWayc4jtpmWOhsWheQPn%2Fld4Xj2J8L5%2BlIrjY7q2DdfUUSFCAA9slEV7hno9bN7l%2F5Sp85nLnr01LnNDf4fKx%2Fv9ee5HcD73sgV1EHwGwPw2aWLTwsoNV0og%3D%3D&sign_type=RSA2"
    
    //高德地图
    static let GaodeMapAPIKey = "ea9b66a31d7743b2a706fbdf40cde51d"
    //融云Cloud
//     static let RongCloudAPIKey = "y745wfm8yji4v" //测试
    static let RongCloudAPIKey = "p5tvi9dspn2t4"
    //Bugly
    static let BuglyAPIKey = "c461e4a068"
    //JPush
    static let JPush_APP_Key = "7bba7ead1f34609f714fab94"
    
    //分享健身记录数据
    static let Share_Training_Data = "https://www.ppbody.com/mobile/share/trainingData"
    
    //分享动态内容
    static let Share_Topic = "https://www.ppbody.com/mobile/share/topic"
    
    // 成为推广大使
    static let Represent_Become = "https://www.ppbody.com/mobile/represent"
    
    // 推广大使详情
    static let Represent_Detail = "https://www.ppbody.com/mobile/representDetail"

    
    // 健身房详情
    static let Gym_Detail = "https://www.ppbody.com/mobile/gymInfo"
    
    // 充值协议
    static let AddMoneyPro = "https://www.ppbody.com/mobile/ppAgreement"
    
    //Error 信息
    static let ErrorMsg = ["error_01":"服务器异常,CEO正在狂扁程序猿",
                           "error_02":"您的用户已被冻结,请尽快联系芝家工作人员,查明原因",
                           "error_04":"用户名或密码错误",
                           "error_06":"手机号被占用",
                           "error_08":"验证码发送失败",
                           "error_09":"验证码不正确",
                           "error_10":"验证码已过期，请重新发送验证码",
                           "error_12":"手机号未注册用户",
                           "error_19":"不能跟自己发送订单",
                           "error_21":"您已收藏过",
                           "error_23":"必填参数为空或参数错误",
                           "error_24":"用户已经存在",
                           "error_25":"数据异常，请刷新后重试",
                           "error_26":"房源已经存在已支付的订单",
                           "error_27":"身份证号已经存在了",
                           "error_28":"经纪人已经发布过房源，不能重复发布",
                           "error_29":"该账号不是经纪人账号",
                           "error_30":"该手机号已经绑定相应的身份证信息",
                           "error_31":"该手机号为用户账号，请走用户申请流程",
                           "error_32":"您已接过此单，不能重复接单",
                           "error_33":"不能接收自己发布的订单",
                           "error_34":"非法操作",
                           "error_35":"经纪人与房屋信息不匹配",
                           "error_36":"此账号没审核通过",
                           "error_37":"此需求已经有60人接单",
                           "error_38":"此账户已经绑定过其他第三方",
                           "error_39":"您已申请过经纪人",
                           "error_40":"此房源不在上架状态",
                           "error_41" : "会员子账户已经存在",
                           "error_42" : "此房屋已在交易中，购买失败",
                           "error_43" : "银行系统故障，CEO正在找他们麻烦",
                           "error_44" : "银行系统故障，CEO正在找他们麻烦",
                           "error_45" : "此卡号已被绑定",
                           "error_46" : "支付短信发送过于频繁，休息一下",
                           "error_47" : "您已经向这用户已发起过此订单",
                           "error_50" : "[平安支付]交易金额超限，请确认支付卡的支付额度！"
                           ]
    
    //获取错误信息显示
    static func getErrorMsg(_ code: String) -> String
    {
//        if ErrorMsg.keys.contains(code)
//        {
//            return ErrorMsg[code]!
//        }else
//        {
            return code
//        }
    }
}
