//
//  SharePlatformView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/11/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

enum ShareType {
    case training
    case topic
    case banner
    /// 团购
    case lbs_gb
    /// 体验课
    case lbs_exp
    /// 商品
    case goods
    /// 长途
    case longImage
}

class SharePlatformView: UIView, AttPriceProtocol, ActivityTimeProtocol {
    
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    /// 分享数据
    var dataDic:[String:Any]?
    /// 分享图片
    var image: UIImage?
    /// 分享类型
    private var shareType: ShareType = .topic
    /// 举报的 handler
    var reportHandler: (()->())?
    /// 保存图片
    var saveHandler: ((UIImage)->())?
    
    // lbs 分享相关
    @IBOutlet private weak var lbsView: UIView!
    
    @IBOutlet private weak var lbsBgView: UIView!
    
    @IBOutlet private weak var lbsBottomView: UIView!
    
    @IBOutlet private weak var imgIV: UIImageView!
    
    @IBOutlet private weak var qrIV: UIImageView!
    
    @IBOutlet private weak var nameLB: UILabel!
    /// 55 10
    @IBOutlet weak var nameRightLC: NSLayoutConstraint!
    
    @IBOutlet private weak var typeIV: UIImageView!
    
    @IBOutlet private weak var addressLB: UILabel!
    
    @IBOutlet private weak var priceLB: UILabel!
    
    @IBOutlet private weak var opriceLB: UILabel!
    
    private lazy var isActivity: Bool = checkActivityDate()
    
    private var shareItems: [[String : String]] {
        switch shareType {
        case .topic:
            return [
                ["icon" : "jubao", "title" : "举报"],
                ["icon" : "share_wechat_icon", "title" : "微信好友"],
                ["icon" : "share_wechat_circle_icon", "title" : "朋友圈"],
                ["icon" : "share_qq_space_icon", "title" : "QQ空间"],
                ["icon" : "share_qq_icon", "title" : "QQ好友"],
                ["icon" : "share_weibo_icon", "title" : "微博"]
            ]
        default:
            return [
                ["icon" : "share_wechat_icon", "title" : "微信好友"],
                ["icon" : "share_wechat_circle_icon", "title" : "朋友圈"],
                ["icon" : "share_qq_space_icon", "title" : "QQ空间"],
                ["icon" : "share_qq_icon", "title" : "QQ好友"],
                ["icon" : "share_weibo_icon", "title" : "微博"]
            ]
        }
    }
        
    class func instanceFromNib() -> SharePlatformView {
        let view = UINib(nibName: "SharePlatformView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SharePlatformView
        view.frame = ScreenBounds
        return view
    }
    
    func initUI(_ type: ShareType) {
        self.shareType = type
        addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(removeView))
        )
        for index in 0..<shareItems.count {
            let dic = shareItems[index]
            let shareItemView = ShareItemView.instanceFromNib()
            shareItemView.setData(dic)
            shareItemView.tag = index + 10
            shareItemView.addGestureRecognizer(
                UITapGestureRecognizer(target: self,
                                action: #selector(tapShareIcon(_:)))
            )
            stackview.addArrangedSubview(shareItemView)
        }
        func addLongPress() {
            let long = UILongPressGestureRecognizer(
                target: self,
                action: #selector(saveAction(_:)))
            lbsView.addGestureRecognizer(long)
        }
        switch type {
        case .goods:
            nameRightLC.constant = 10
            addLongPress()
        case .lbs_gb,
             .lbs_exp:
            nameRightLC.constant = 55
            addLongPress()
        default:
            break
        }
    }
    
    func ptExpUpdateUI(_ expData: [String : Any], url: String) {
        typeIV.image = UIImage(named: "lbs_share_ptexp")
        imgIV.setCoverImageUrl(expData.stringValue("cover") ?? "")
        nameLB.text = expData.stringValue("name")
        let name = expData.stringValue("clubName") ?? ""
        let address = expData.stringValue("region") ?? ""
        addressLB.text = name + " | " + address
        qrIV.image = dzy_QrCode(url, size: 81.0 * ScreenScale)
        
        let price = expData.doubleValue("presentPrice") ?? 0
        priceLB.attributedText = attPriceStr(price,
                                    signFont: dzy_FontBBlod(12),
                                    priceFont: dzy_FontBBlod(24),
                                    fontColor: dzy_HexColor(0xEF343B))
        let oprice = expData.doubleValue("originPrice") ?? 0
        opriceLB.text = "¥" + oprice.decimalStr
    }
    
    func gbUpdateUI(_ gbData: [String : Any], url: String) {
        typeIV.image = UIImage(named: "lbs_share_gb")
        imgIV.setCoverImageUrl(gbData.stringValue("cover") ?? "")
        nameLB.text = gbData.stringValue("name")
        let name = gbData.stringValue("clubName") ?? ""
        let address = gbData.stringValue("region") ?? ""
        addressLB.text = name + " | " + address
        qrIV.image = dzy_QrCode(url, size: 81.0 * ScreenScale)
        
        var price = 0.0
        if isActivity,
            let aprice = gbData.doubleValue("activityPrice"),
            aprice > 0
        {
            price = aprice
        }else {
            price = gbData.doubleValue("presentPrice") ?? 0
        }
        priceLB.attributedText = attPriceStr(price,
                                    signFont: dzy_FontBBlod(12),
                                    priceFont: dzy_FontBBlod(24),
                                    fontColor: dzy_HexColor(0xEF343B))
        let oprice = gbData.doubleValue("originPrice") ?? 0
        opriceLB.text = "¥" + oprice.decimalStr
    }
    
    func goodsUpdateUI(_ data: [String : Any], url: String) {
        typeIV.isHidden = true
        imgIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        nameLB.text = data.stringValue("title")
        addressLB.text = nil
        qrIV.image = dzy_QrCode(url, size: 81.0 * ScreenScale)
        
        let price = data.doubleValue("presentPrice") ?? 0
        priceLB.attributedText = attPriceStr(price,
                                    signFont: dzy_FontBBlod(12),
                                    priceFont: dzy_FontBBlod(24),
                                    fontColor: dzy_HexColor(0xEF343B))
        let oprice = data.doubleValue("originPrice") ?? 0
        opriceLB.text = "¥" + oprice.decimalStr
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toSuperview: newWindow)
        self.bottomMargin.constant = 0
        UIView.animate(withDuration: 0.25) {
            switch self.shareType {
            case .lbs_gb,
                 .lbs_exp,
                 .goods:
                self.lbsView.alpha = 1
            default:
                self.lbsView.alpha = 0
            }
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
//    MARK: - 保存
    @objc private func saveAction(_ long: UILongPressGestureRecognizer) {
        if long.state == .began,
            let image = viewCopy(lbsBgView) {
            saveHandler?(image)
        }
    }
    
//    MARK: - 关闭、移除
    @IBAction private func closeAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @objc func removeView() {
        removeFromSuperview()
    }
    
    @objc private func tapShareIcon(_ tap: UITapGestureRecognizer) {
        let tag = tap.view?.tag
        switch shareType {
        case .topic:
            switch tag {
            case 10:
                removeFromSuperview()
                reportHandler?()
            case 11:
                shareInfo(SSDKPlatformType.subTypeWechatSession)
            case 12:
                shareInfo(SSDKPlatformType.subTypeWechatTimeline)
            case 13:
                shareInfo(SSDKPlatformType.subTypeQZone)
            case 14:
                shareInfo(SSDKPlatformType.subTypeQQFriend)
            case 15:
                shareInfo(SSDKPlatformType.typeSinaWeibo)
            default:
                break
            }
        default:
            switch tag {
            case 10:
                shareInfo(SSDKPlatformType.subTypeWechatSession)
            case 11:
                shareInfo(SSDKPlatformType.subTypeWechatTimeline)
            case 12:
                shareInfo(SSDKPlatformType.subTypeQZone)
            case 13:
                shareInfo(SSDKPlatformType.subTypeQQFriend)
            case 14:
                shareInfo(SSDKPlatformType.typeSinaWeibo)
            default:
                break
            }
        }
    }
    
    private func shareInfo(_ type:SSDKPlatformType) {
        switch shareType {
        case .banner:
            //webview 分享
            let cover = self.dataDic!["cover"] as! String
            let content = self.dataDic!["title"] as! String
            let url = self.dataDic!["url"] as! String
            let shareParams = NSMutableDictionary()
            shareParams.ssdkSetupShareParams(byText: "每一滴汗水都值得被记录！", images: cover, url: URL(string: url), title: "PPbody|" + content , type: SSDKContentType.webPage)
            
            ShareSDK.share(type, parameters: shareParams) { (state, info, enity, error) in
                if state == .success
                {
                    
                }
            }
        case .lbs_gb,
             .lbs_exp,
             .goods:
            guard let image = viewCopy(lbsBgView) else {return}
            let shareParams = NSMutableDictionary()
            shareParams.ssdkSetupShareParams(byText: "", images: image, url: nil, title: "PPbody", type: .image)
            ShareSDK.share(type, parameters: shareParams) { (state, info, enity, error) in
                if state == .success
                {
                    
                }
            }
        case .longImage:
            guard let image = image else {return}
            let shareParams = NSMutableDictionary()
            shareParams.ssdkSetupShareParams(byText: "", images: image, url: nil, title: "PPbody", type: .image)
            ShareSDK.share(type, parameters: shareParams) { (state, info, enity, error) in
                if state == .success
                {
                    
                }
            }
        default:
            let cover = self.dataDic!["cover"] as! String
            let content = self.dataDic!["content"] as! String
            let shareParams = NSMutableDictionary()
            shareParams.ssdkSetupShareParams(byText: "每一滴汗水都值得被记录！", images: cover, url: URL(string: Config.Share_Topic + "?tid=" + (self.dataDic!["tid"] as! String)), title: "PPbody|" + content , type: SSDKContentType.webPage)
            
            ShareSDK.share(type, parameters: shareParams) { (state, info, enity, error) in
                
                if state == .success
                {
                    
                }
            }
            let request = BaseRequest()
            request.dic = ["type":"10" , "tid":self.dataDic!["tid"] as! String]
            request.url = BaseURL.ShareSuccess
            request.isUser = true
            request.start { (data, error) in
                guard error == nil else
                {
                    //执行错误信息
                    return
                }
            }
        }
    }
}
