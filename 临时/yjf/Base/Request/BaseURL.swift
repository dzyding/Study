//
//  BaseURL.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/21.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import UIKit

class HostManager {
    
    static let `default` = HostManager()
    
//    var host = "https://qx1024.com"
    
    var host = "https://www2.ejfun.com"
    
//       var host = "http://192.168.10.222"
}

enum BaseURL: String {
    //    MARK: - User
    /// 切换身份
    case changeIdentity = "user/userCutType"
    
    /// 切换城市
    case changeCity = "user/userCutCity"
    
    /// 设置跳过交易流程培训
    case jumpTrain = "user/buyTrain"
    
    /// 发送验证码
    case sendVerCode = "user/sendVerCode"
    
    /// 验证验证码
    case checkMobileCode = "user/checkMobileCode"
    
    /// 注册
    case regist = "user/registerUser"
    
    /// 验证码登录
    case mobileLogin = "user/mobileLogin"
    
    /// 账号密码登录
    case pwdLogin = "user/userLogin"
    
    /// 上次的登录方式
    case lastLoginType = "user/userLoginType"
    
    /// 验证密码是否正确
    case checkPwd = "user/checkPassword"
    
    /// 用户详情
    case userDetail = "user/userDetail"
    
    /// 编辑用户详情
    case editUser = "user/editUser"
    
    /// 设置密码 *
    case setPwd = "user/updateUserPassword"
    
    /// 提交反馈
    case submitFeed = "evaluate/submitProposal"
    
    /// 收藏房源
    case collectHouse = "user/collectHouse"
    
    /// 我的收藏
    case myCollect = "user/collectHouseList"
    
    /// 批量取消收藏
    case batchCancelCollect = "user/deleteCollectHouse"
    
    /// 关注房源
    case attentionHouse = "user/concernHouse"
    
    /// 我的关注
    case myAttention = "user/concernHouseList"
    
    /// 批量取消关注
    case batchCancelAttention = "user/deleteConcernHouse"
    
    /// 添加房源
    case editHouse = "user/editUserHouse"
    
    /// 卖家报价
    case sellerAddMoney = "user/userOffer"
    
    /// 卖家撤销报价
    case sellerDelMoney = "user/deleteUserOffer"
    
    /// 买家出价
    case buyerAddMoney = "user/userHouseBid"
    
    /// 批量撤销竞买
    case buyerDelMoney = "user/deleteHouseBuy"
    
    /// 我的房源列表
    case sellerHouseList = "user/userHouseList"
    
    /// 撤销房源
    case undoHouse = "user/revocationHouse"
    
    /// 我的竞买列表
    case buyerBidList = "user/userHouseBuy"
    
    /// 添加浏览记录
    case addFootMark = "user/browseHouse"
    
    /// 用户的浏览记录列表
    case footMarkList = "user/browseHouseList"
    
    /// 优显列表
    case topList = "user/topHouseList"
    
    /// 优显详情
    case topDetail = "user/houseTopDetail"
    
    /// 优先详情列表
    case topDetailList = "user/houseTopRecordList"
    
    /// 优显暂停 *
    case topStopOrStart = "user/houseTopStop"
    
    /// 优显退款 *
    case topRefund = "user/houseTopRefund"
    
    /// 成交前的检查 *
    case dealCheck = "user/checkHouseBuy"
    
    /// 成交 *
    case buySuccess = "user/houseBuySuccess"
    
    /// 我的成交 (我的竞买，已成交) *
    case mySuccess = "user/buyHouseRecordList"
    
    /// 申请拆/装锁 *
    case installLock = "user/userInstallLock"
    
    /// 支出帐号 *
    case amount = "user/userAmountDetail"
    
    /// 支出明细 *
    case amountDetail = "user/expenditureLogList"
    
    /// 交易进展 *
    case orderProgress = "user/sellHouseProgress"
    
    /// 行为记录 *
    case userOperFooter = "user/recordUserOperate"
    
    /// 评价房源列表 或者 可评价其他服务列表*
    case taskHouseList = "anapTask/houTaskList"
    
    /// 房源相关的可评价任务列表 *
    case taskList = "anapTask/houTaskEvaluateList"
    
    /// 评价配置信息 *
    case evaluateConfig = "task/getTaskConfig"
    
    /// 评价详情 *
    case evaluateDetail = "anapTask/taskEvaluateDetail"
    
    /// 评价 *
    case evaluate = "anapTask/userEvaluateTask"
    
    /// 消息首页 *
    case message = "user/userMessageFirst"
    
    /// 消息列表 *
    case messageList = "user/userMessageList"
    
    /// 阅读消息 *
    case readMessage = "user/readUserMessage"
    
    /// 看房记录 *
    case lookHouseList = "user/userLookHouseList"
    
    /// 佣金折扣 *
    case userAssist = "user/userAssistDetail"
    
    /// 退回保证金等 *
    case refundPrice = "user/userRefundPrice"
    
    /// 提现 *
    case takePrice = "user/userTakePrice"
    
    /// 检查房源状态
    case checkHouseType = "user/getHouseType"
    
    //    MARK: - LOCK
    /// 根据门锁获取房源信息 *
    case houseDetailFromCode = "lock/houseLockDetail"
    
    /// 根据房源获取门锁，房源相关信息 *
    case houseDetailFromId = "lock/houseDetailLock"
    
    /// 获取开锁密码 *
    case lockPwd = "lock/getLockPassword"
    
    /// 开锁后开始计时 *
    case beginLookHouse = "lock/openHouseLock"
    
    /// 关闭看房 *
    case closeLookHouse = "lock/closeLockOpen"
    
    /// 生成买方看房报告 *
    case buyerLookMsg = "lock/createUserLookHouse"
    
    /// 生成卖方损毁报告 *
    case sellerLookMsg = "lock/sellLookHouse"
    
    /// 判断是否正在看房 *
    case checkIsInHouse = "lock/judgeLookHouse"
    
    /// 看房快结束时，更新用户位置信息 *
    case updateLookAddress = "lock/getUserAddress"
    
    /// 卖家看房重新计时 *
    case sellerUpdateTime = "lock/anewLockTime"
    
    /// 密码开锁检查门的状态
    case openLockType = "lock/getLockStatus"
    
    //    MARK: - PC
    /// 区域下的房源统计
    case regionList = "pc/regionList"
    
    /// 所有的区域信息
    case allRegion = "pc/regionGanged"
    
    /// 首页房源列表
    case houseList = "pc/houseList"
    
    /// 离某经纬度最近的城市
    case nearestCity = "pc/firstRegion"
    
    /// 房源详情
    case houseDetail = "pc/houseDetail"
    
    /// 房源详情(撤销的房源重新发布时使用) *
    case releaseUndoDetail = "/user/houseDetail"
    
    /// 竞价详情
    case bidDetail = "pc/houseBiddingDetail"
    
    /// 查看是否跳过培训，是否交保证金
    case payOrTrainType = "pc/userPayType"
    
    /// 城市列表
    case cityList = "pc/cityList"
    
    /// 地图找房 *
    case mapSearch = "pc/mapSeekHouse"
    
    /// 根据小区找房 *
    case mapHouseList = "pc/mapHouseList"
    
    /// 城市下的所有行政区 *
    case mapRegion = "pc/mapRegion"
    
    /// 城市配置 *
    case cityConfig = "pc/getCityConfig"
    
    /// 系统配置 *
    case sysConfig = "pc/getSysConfig"
    
    /// 报告门锁故障 *
    case reportLock = "pc/userReportLock"
    
    /// 版本更新 *
    case appVersion = "pc/getAppVersions"
    
    /// banner *
    case bannerList = "pc/bannerList"
    
    /// 问答界面，获取问题关联 key *
    case assQuestionList = "pc/consultationTitleAll"
    
    /// 房产新闻 *
    case newsList = "pc/marketQuotationList"
    
    /// 房产新闻详情
    case newsDetail = "pc/marketQuotationDetail"
    
    /// 咨询首页的大标题 *
    case consultList = "pc/consultationList"
    
    /// 咨询详情 *
    case consultDetail = "pc/getConsultation"
    
    /// 常见问题 *
    case commonQaList = "pc/consultationQAList"
    
    /// 获取问题的答案 *
    case questionDetail = "pc/consultationQADetail"
    
    /// 搜索小区 *
    case searchCommunit = "pc/getCommunitKey"
    
    /// 价格曲线 *
    case comGraph = "pc/houseGraph"
    
    /// 成交记录 *
    case dealList = "pc/houseRecordList"
    
    //    MARK: - other
    /// 上传图片
    case uploadPic = "common/pic"
    
    /// 生成验证码图片
    case imageCode = "mutual/images/imagecode"
    
    /// 微信支付
    case wechatPay = "pay/wechat"
    
    /// 支付宝支付
    case aliPay = "pay/alipay"
    
    /// 所有未交门锁押金的房源 *
    case notLockList = "pay/houseNotLockList"
}
