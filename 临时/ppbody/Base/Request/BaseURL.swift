//
//  BaseURL.swift
//  ZAJA
//
//  Created by Nathan_he on 16/9/7.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation

open class BaseURL
{
    
    static let LAN = "http://192.168.11.78:8080"
    
    static let HOST1 = "https://www.qx1024.com"
    
    static let HOST2 = "http://test.ppbody.com"
    
   static let HOST = "https://www.ppbody.com"
    
    static let PPBody = HOST2 + "/ppbody/api"
    
    static let Saas = HOST2 + "/ppsaas/api"

//    MARK: - 汗水、钱包
    // 获取当前汗水值 和 当前余额
    static let UserWallet = PPBody + "/user/wallet"
    // 现金流水
    static let MoneyFlow = PPBody + "/user/walletFlow"
    // 提现
    static let TakeMoney = PPBody + "/wechat/money"
    //充值汗水的列表 (商品列表)
    static let RechargeList: String = PPBody + "/coin/rechargeList"
    //我的汗水明细
    static let SweatFlow: String = PPBody + "/coin/sweatFlow"
    //获取当前汗水值
    static let UserSweat = PPBody + "/user/sweat"
    //礼物统计
    static let giftStatistics = PPBody + "/coin/giftStatistics"
    //礼物流水明细
    static let GiftFlow: String = PPBody + "/coin/giftFlow"
    //礼物列表
    static let Gifts: String = PPBody + "/coin/gifts"
    //送礼
    static let GiveGift: String = PPBody + "/coin/giveGift"
    //充值校验
    static let IapVerify: String = PPBody + "/pay/iapVerify"
    //提现
    static let Withdrawal = PPBody + "/pay/withdrawal"
    
    //新增/编辑银行卡
    static let CardEdit = PPBody + "/user/cardEdit"
    //银行卡列表
    static let CardList = PPBody + "/user/cardList"
    //成为默认银行卡
    static let CardBeDefault = PPBody + "/user/cardBeDefault"
    //获取默认银行卡
    static let CardDefault = PPBody + "/user/cardDefault"
    //解除银行卡
    static let CardDelete = PPBody + "/user/cardDelete"
    

//    MARK: - common
    
    //获取视频的封面
    static let VideoCover: String = PPBody + "/common/video/cover"
    
    //城市列表
    static let Citys: String = PPBody + "/common/citys"
    
    //启动页投屏
    static let Splash = PPBody + "/common/splash"

//    MARK: - user
    
    static let Token: String = PPBody + "/user/token"
    
    //修改用户封面
    static let UpdateCover: String = PPBody + "/user/updateCover"
    
    //阿里云OSS STS 上传凭证
    static let UploadSts: String = PPBody + "/aliyun/uploadSts"

    //刷新用户auth
    static let RefreshAuth: String = PPBody + "/user/refresh"
    
    //更新Location
    static let UpdateLocation: String = PPBody + "/user/updateLocation"
    

    //登录
    static let Login: String = PPBody + "/user/login"
    
    //验证码登录
    static let LoginVercode: String = PPBody + "/user/loginVerCode"
    
    //更改用户信息
    static let EditUser : String = PPBody + "/user/edit"
    //发送验证码
    static let Verifycode: String = PPBody + "/user/sendVerCode"
    //找回密码
    static let FindPwd : String = PPBody + "/user/changePassword"
    //我的部落
    static let MyTribe: String = PPBody + "/user/myTribe"
    
    //注册 验证手机号是否注册
    static let VerifyMobile: String = PPBody + "/user/verifyMobile"
    
    //注册 校验验证码是否正确
    static let VerifyRegisterCode: String = PPBody + "/user/verifyMobileCode"
    
    //获取验证码
    static let CommonSendCode: String = PPBody + "/common/sendVerCode"
    
    //注册 昵称判断是否唯一
    static let VerifyNickname = PPBody + "/user/verifyNickname"
    
    //注册
    static let Register = PPBody + "/user/register"
    
    //第三方登录
    static let LoginOtherAPP = PPBody + "/user/loginOtherAPP"
    
    //第三方用户绑定
    static let BandOther = PPBody + "/user/bandOther"

    //意见反馈
    static let FeedBack = PPBody + "/user/feedback"

    // 编辑收获地址
    static let EditAddress = PPBody + "/user/editAddress"
    
    // 删除收获地址
    static let DeleteAddress = PPBody + "/user/deleteAddress"
    
    // 收获地址列表
    static let AddressList = PPBody + "/user/addressList"
    
    // 默认收获地址
    static let DefAddress = PPBody + "/user/defAddress"
    
//    MARK: - 商品
    // 商品列表
    static let GoodsList = PPBody + "/goods/goodsList"
    
    // 商品详情
    static let GoodsDetail = PPBody + "/goods/goodsDetail"
    
    // 提交订单
    static let OrderGoods = PPBody + "/goods/orderGoods"
    
    // 支付
    static let PayOrder = PPBody + "/goods/payOrder"
    
    // 订单列表
    static let GOrderList = PPBody + "/goods/myOrderList"
    
    // 生成分享口令
    static let ShareCode = Saas + "/goods/shareCode"
    
    // 解析口令
    static let ResolveShareCode = Saas + "/goods/resolveShareCode"
    
//    MARK: - 个人中心
    
    //用户个人的关系数据
    static let RelationData = PPBody + "/user/relationData"
    //用户个人的关系数据
    static let MyCoach = PPBody + "/user/myCoach"
    //粉丝列表
    static let FollowList = PPBody + "/user/followList"
    //关注列表
    static let AttentionList = PPBody + "/user/attentionList"
    //关注操作
    static let Attention = PPBody + "/user/attention"
    //我点赞的话题
    static let MySupportTopic = PPBody + "/user/mySupportTopic"
    //我发布的话题
    static let MyPublicTopic = PPBody + "/user/myPublicTopic"
    //查看教练审核状态
    static let ApplyCoachStatus = PPBody + "/user/applyCoachStatus"
    //申请
    static let ApplyCoach = PPBody + "/user/applyCoach"
    //部落详情
    static let TribeDetail = PPBody + "/found/tribeDetail"
    //部落编辑
    static let EditTribe = PPBody + "/found/editTribe"
    //学员的课程列表
    static let MyCourse = PPBody + "/user/myCourse"
    //教练的课程列表
    static let CourseList = PPBody + "/user/courseList"
    //教练历史课程列表
    static let CourseHistoryList = PPBody + "/user/courseHistoryList"
    //教练的自定义计划列表
    static let MotionPlanList = PPBody + "/user/motionPlanList"
    //课程日期选择时间范围
    static let CourseTime = PPBody + "/user/courseTime"
    //计划详情
    static let MotionForPlan = PPBody + "/user/motionForPlan"
    //自定义动作列表
    static let CoachMotionList = PPBody + "/user/motionList"
    //学员的教练计划
    static let MyMotionPlan = PPBody + "/user/myMotionPlan"
    //获取用户信息
    static let UserInfo = PPBody + "/user/info"
    //编辑用户信息
    static let EditUserInfo = PPBody + "/user/editInfo"
    //他人主页
    static let OtherInfo = PPBody + "/user/personalPage"
    //他人话题列表
    static let OtherTopic = PPBody + "/user/otherTopic"
    //成为教练学员
    static let CoachMember = PPBody + "/user/coachMember"
    //收否开启推广大使模块
    static let OpenSpread = PPBody + "/user/openSpread"
    //是否为推广大使
    static let IfRepresent = PPBody + "/user/ifRepresent"
    //取消推广大使
    static let cancelRepresent = PPBody + "/user/cancelRepresent"
    // 拉黑
    static let BecomeBlack = PPBody + "/user/black"
    // 拉黑列表
    static let BlackList = PPBody + "/user/blackList"

//    MARK: - 教练
    
    //教练学员列表
    static let CoachMemberList = PPBody + "/user/coachMemberList"
    //教练添加课程给学员
    static let AddCourse = PPBody + "/user/addCourse"
    //教练删除课程
    static let DeleteCourse = PPBody + "/user/deleteCourse"
    //获取课程的详情
    static let CourseDetail = PPBody + "/user/courseDetail"
    //添加课程的详情
    static let AddCourseDetail = PPBody + "/user/addCourseDetail"
    //教练删除自定义计划
    static let DeleteMotionPlan = PPBody + "/user/deleteMotionPlan"
    //教练删除自定义计划里面的动作
    static let DeleteMotionForPlan = PPBody + "/user/deleteMotionForPlan"
    //教练新增自定义计划 或编辑
    static let EditMotionPlan = PPBody + "/user/editMotionPlan"
    //备注会员昵称
    static let RemarkMember = PPBody + "/user/remarkMember"

//    MARK: - 首页
    
    //日历显示训练程度
    static let Calendar = PPBody + "/user/calendar"
    //每日的数据接口情况
    static let DailyData = PPBody + "/user/daily"
    
//    MARK: - 训练
    
    //动作列表
    static let MotionList = PPBody + "/training/motionList"
    //添加体态数据
    static let AddBodyData = PPBody + "/training/addBodyData"
    //获取体态数据
    static let BodyData = PPBody + "/training/bodyData"
    //动作搜索
    static let SearchMotion = PPBody + "/training/motionSearch"
    /// 删除动作组
    static let DelMotionGroup = PPBody + "/training/deleteMotionGroup"
    /// 编辑动作组
    static let EditMotionGroup = PPBody + "/training/editMotionGroup"
    /// 发布训练的动作
    static let AddTrainingData = PPBody + "/v2/training/add"
    /// 记录训练数据 （计划）
    static let AddPlanData = PPBody + "/v2/training/addPlanData"
    /// 用户编辑训练计划
    static let UserEditMotionPlan = PPBody + "/v2/training/editMotionPlan"
    /// 查看某一天的计划
    static let MotionPlanWeek = PPBody + "/v2/training/motionPlanWeek"
    /// 编辑某一天的计划
    static let EditMotionPlanWeek = PPBody + "/v2/training/editMotionPlanWeek"
    /// 查看计划详情
    static let MotionPlanDetail = PPBody + "/v2/training/motionPlanDetail"
    /// 查看周计划详情
    static let MotionPlanWeekDetail = PPBody + "/v2/training/motionPlanWeekDetail"
    /// 删除周训练计划
    static let MotionPlanWeekDelete = PPBody + "/v2/training/motionPlanWeekDelete"
    ///教练新增自定义动作 或编辑
    static let EditMotion = PPBody + "/v2/training/editMotion"
    ///教练删除自定义动作
    static let DeleteMotion = PPBody + "/user/deleteMotion"
    ///半年的记录数据
    static let HalfYear = PPBody + "/v2/training/halfYear"
    /// 本周数据概览
    static let WeekOverView = PPBody + "/v2/training/overview"
    /// 训练轨迹
    static let TrainingHis = PPBody + "/user/trainingHistory"
    /// 训练详情
    static let TrainDetail = PPBody + "/user/trainingDetail"
    /// 编辑训练
    static let TrainEdit = PPBody + "/user/trainingEdit"
    /// 训练首页
    static let TrainingHome = PPBody + "/v2/training/home"
    
//    MARK: - 统计
    
    // 广告点击统计
    static let AdSt = PPBody + "/statistics/adSt"
    
    //部位总览
    static let PlanOverview = PPBody + "/statistics/planOverview"
    //每个部位的训练动作的预览
    static let PlanMotion = PPBody + "/statistics/planMotion"
    //体态统计最近16次
    static let LastBodyData = PPBody + "/statistics/lastBodyData"
    //动作数据列表
    static let MotionData = PPBody + "/statistics/motionData"
    //动作数据列表
    static let BodyPart = PPBody + "/statistics/bodyPart"
    /// 体态单个部位的最近 16 次记录
    static let OneBodyData = PPBody + "/statistics/lastOneBodyData"
    
//    MARK: - 发现
    
    //热门标签
    static let HotTag: String = PPBody + "/found/hotTag"
    //Banner和标签
    static let TagBanner: String = PPBody + "/found/tagBanner"
    // 标签列表
    static let TagList = PPBody + "/found/tagList"
    //推荐标签
    static let RecommendTag: String = PPBody + "/found/recommendTag"
    //标签详情
    static let TagDetail: String = PPBody + "/found/tagDetail"
    //标签下话题列表
    static let TagTopicList: String = PPBody + "/found/topicTagList"
    //热门部落
    static let HotTribe: String = PPBody + "/found/hotTribe"
    //搜索标签
    static let SearchTag: String = PPBody + "/found/searchTag"
    //发现、首页话题列表
    static let TopicList: String = PPBody + "/v2/found/topicList"
    //话题标签打卡
    static let clockTopicTag = PPBody + "/found/clockTopicTag"
    //发布话题
    static let PublicTopic: String = PPBody + "/found/publicTopic"
    //删除话题
    static let DeleteTopic: String = PPBody + "/found/deleteTopic"
    //点赞话题
    static let SupportTopic: String = PPBody + "/found/supportTopic"
    //评论话题
    static let TopicCommentPublic: String = PPBody + "/found/topicCommentPublic"
    //话题的评论列表
    static let TopicCommentList: String = PPBody + "/found/topicCommentList"
    //点赞话题评论
    static let SupportTopicComment: String = PPBody + "/found/supportTopicComment"
    //部落的热门和最新话题列表
    static let TopicForTribeId = PPBody + "/found/topicForTribeId"
    //删除评论
    static let DeleteTopicComment: String = PPBody + "/found/deleteTopicComment"
    //热门搜索关键词
    static let SearchHot = PPBody + "/found/searchHot"
    //搜索用户
    static let SearchPersonal: String = PPBody + "/found/searchPersonal"
    //搜索话题标签
    static let SearchTopicTag: String = PPBody + "/found/searchTopicTag"
    //推荐用户
    static let RecommondUser = PPBody + "/found/recommendUser"
    //推荐部落
    static let RecommondTribe = PPBody + "/found/recommendTribe"
    // 举报
    static let Accusation = PPBody + "/found/accusation"
    
//    MARK: - 音乐
    
    //热门音乐
    static let HotMusic: String = PPBody + "/found/hotMusic"
    //收藏和取消收藏音乐
    static let CollectMusic: String = PPBody + "/found/collectMusic"
    //我收藏的音乐
    static let CollectionMusic: String = PPBody + "/user/collectionMusic"

//    MARK: - Pay

    //微信支付下订单
//    static let WechatPayPreOrder: String = PPBody + "/pay/wechat"
    //支付宝下订单
//    static let AliPayPreOrder: String = PPBody + "/pay/alipay"
    
//    MARK: - Message
    
    //消息获取
    static let MessageNotify: String = PPBody + "/msg/notify"
    //检查IM聊天是否支付
    static let PayIM: String = PPBody + "/msg/payIM"
    //消息中心 话题评论列表
    static let MsgTopicCommentList: String = PPBody + "/msg/topicCommentList"
    //消息中心 关注列表
    static let MsgUserFollowList: String = PPBody + "/msg/userFollowList"
    //消息中心 点赞列表
    static let MsgTopicSupportList: String = PPBody + "/msg/topicSupportList"
    //消息中心 @列表
    static let MsgTopicDirectionList: String = PPBody + "/msg/topicDirectionList"
    //消息中心 清除
    static let MsgClearNotify: String = PPBody + "/msg/clearMsgNotify"
    
//    MARK: - Share
    
    //分享计数
    static let ShareSuccess: String = PPBody + "/user/share"

    //获取视频的播放地址
    static let GetVideoURL = PPBody + "/common/video/odurl"

//    MARK: - RedMoney
    
    //判断是否绑定微信
    static let IfWechat: String = PPBody + "/user/ifWechat"
    
    //绑定微信
    static let BandWechat = PPBody + "/user/bandWechat"
    
//    MARK: - saas
    
    // 获取用户俱乐部
    static let Clubs = PPBody + "/saas/clubs"
    
    // 绑定和解绑健身房
    static let ClubAction = PPBody + "/saas/clubAction"
    
    // 我的健身房
    static let MyClub = PPBody + "/saas/myClub"
    
    // 查看用户是否有课进行中
    static let MyIngCourse = PPBody + "/saas/myCourse"
    
    // 我的健身房详情
    static let MyClubInfo = Saas + "/app/clubInfo"
    
    // 教练列表
    static let PtList = Saas + "/app/ptList"
    
    // 私教预约列表
    static let ReservePtList = Saas + "/app/reservePtList"
    
    // 团课信息
    static let GroupClassList = Saas + "/app/groupList"
    
    // 团课预约
    static let ClassReserve = Saas + "/app/reserve"
    
    // 私教预约
    static let PtReserve = Saas + "/app/ptReserve"
    
    // 私教预约取消
    static let CancelPtReserve = Saas + "/app/cancelPtReserve"
    
    // 我的健身房(教练)
    static let CoachClub = Saas + "/app/ptInfo"
    
    // 私教预约列表(教练)
    static let ReserveList_Pt = Saas + "/app/ptReserveList"
    
    // 私教会员列表(教练)
    static let MemberList = Saas + "/app/ptMemberList"
    
    // 本月上课流水(教练)
    static let MonthClassList = Saas + "/app/ptClassMonthList"
    
    // 本月业绩流水(教练)
    static let MonthSellList = Saas + "/app/ptContractMonthList"
    
    // 私教预约配置查询
    static let PtConfig = Saas + "/app/ptConfig"
    
    // 私教预约配置编辑
    static let PtEditConfig = Saas + "/app/editConfig"
    
    // 扫码获取学员课程列表
    static let ScanCourseCode = Saas + "/app/scanCourseCode"
    
    // 私教核销课程
    static let ReduceCourse = Saas + "/app/reduceCourse"
    
    // 打卡记录
    static let EntryFlow = Saas + "/app/entryFlow"
    
    // 学员核销记录
    static let CourseHistory = Saas + "/member/courseHistory"
    
    // 学员课程列表
    static let Classes = Saas + "/member/classes"
    
//    MARK: - LBS
    /// 城市列表
    static let CityList = Saas + "/lbs/cityList"
    /// 排序的区域
    static let RegionList = Saas + "/lbs/regionList"
    /// 健身房列表
    static let ClubList = Saas + "/lbs/clubList"
    /// 健身房详情
    static let ClubDetail = Saas + "/lbs/clubDetail"
    /// 附近推荐健身房
    static let ClubRecommend = Saas + "/lbs/clubRecommend"
    /// 团购详情
    static let GroupBuyDetail = Saas + "/lbs/groupBuyDetail"
    /// 体验课详情
    static let PtExpDetail = Saas + "/lbs/ptExpDetail"
    /// 提交订单
    static let LSubmitOrder = Saas + "/lbs/orderGood"
    /// 支付订单
    static let LPayOrder = Saas + "/lbs/payOrder"
    /// 体验课，可预约教练列表
    static let LPtList = Saas + "/lbs/clubPtList"
    /// 订单列表
    static let LOrderList = Saas + "/lbs/orderList"
    /// 订单详情
    static let LOrderDetail = Saas + "/lbs/orderDetail"
    /// 删除订单
    static let LOrderDel = Saas + "/lbs/orderDelete"
    /// 订单退款
    static let LOrderRefund = Saas + "/lbs/orderRefund"
    /// 收藏健身房
    static let CollectClub = Saas + "/lbs/collectClub"
    /// 健身房收藏列表
    static let CollectClubList = Saas + "/lbs/collectClubList"
    /// 收藏团购 私教体验 团操体验
    static let CollectClubGood = Saas + "/lbs/collectClubGood"
    /// 收藏的健身房商品列表
    static let CollectClubGoodList = Saas + "/lbs/collectClubGoodList"
    /// 热门搜索
    static let ClubSearchHot = Saas + "/lbs/searchHot"
    /// 俱乐部评论
    static let ClubComment = Saas + "/lbs/comment"
    /// 评价列表
    static let CommentList = Saas + "/lbs/commentList"
    /// 双十二活动专区的列表
    static let T12List = Saas + "/t12/list"
}
