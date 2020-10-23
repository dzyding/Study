//
//  ShareVC.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol ShareVCProtocol where Self: BaseVC {
    var url: String? {get}
    var wechatUrl: String? {get}
    var weiboUrl: String? {get}
    
    func shareBaseFun()
}

extension ShareVCProtocol {
    /// 二维码的内容
    var url: String? {
        guard let code = DataManager.user()?.stringValue("code") else {
            return nil
        }
        return HostManager.default.host + "/yjf/reference/user/\(code)/cutCommission/qrcode"
    }
    
    /// 微信分享出去的链接
    var wechatUrl: String? {
        guard let code = DataManager.user()?.stringValue("code") else {
            return nil
        }
        return HostManager.default.host + "/yjf/reference/user/\(code)/cutCommission/weixin"
    }
    
    /// 微博分享出去的链接
    var weiboUrl: String? {
        guard let code = DataManager.user()?.stringValue("code") else {
            return nil
        }
        return HostManager.default.host + "/yjf/reference/user/\(code)/cutCommission/weibo"
    }
    
    func shareBaseFun() {
        let params = NSMutableDictionary()
        let image = "http://yjfang-img.obs.cn-south-1.myhuaweicloud.com/image/cf7bb1cb5e5b878c52368dc4d920eb21.jpg"
        guard let url = URL(string: url ?? ""),
            let wechatUrl = URL(string: wechatUrl ?? ""),
            let weiboUrl = URL(string: weiboUrl ?? "")
            else {return}
        params.ssdkSetupShareParams(
            byText: "一个可以自助看房、线上议价的房屋交易平台。",
            images: image,
            url: url,
            title: "易间房，一个家",
            type: .webPage
        )
        [
            SSDKPlatformType.subTypeWechatSession,
            SSDKPlatformType.subTypeWechatTimeline
            ].forEach { (type) in
                params.ssdkSetupWeChatParams(byText: "一个可以自助看房、线上议价的房屋交易平台。", title: "易间房，一个家", url: wechatUrl, thumbImage: image, image: image, musicFileURL: nil, extInfo: nil, fileData: nil, emoticonData: nil, sourceFileExtension: nil, sourceFileData: nil, type: .webPage, forPlatformSubType: type)
        }
        params.ssdkSetupSinaWeiboShareParams(byText: "一个可以自助看房、线上议价的房屋交易平台。", title: "易间房，一个家", images: [image], video: nil, url: weiboUrl, latitude: 0, longitude: 0, objectID: nil, isShareToStory: false, type: .webPage)
        var items: [UInt] = []
        if ShareSDK.isClientInstalled(.typeWechat) {
            items += [
                SSDKPlatformType.subTypeWechatSession.rawValue,
                SSDKPlatformType.subTypeWechatTimeline.rawValue
            ]
        }
        if ShareSDK.isClientInstalled(.typeSinaWeibo) {
            items += [
                SSDKPlatformType.typeSinaWeibo.rawValue
            ]
        }
        //        if ShareSDK.isClientInstalled(.typeQQ) {
        //            items += [
        //                SSDKPlatformType.typeQQ.rawValue
        //            ]
        //        }
        let config = SSUIShareSheetConfiguration()
        config.style = .system
        config.menuBackgroundColor = .white
        
        ShareSDK.showShareActionSheet(nil,
                                      customItems: items,
                                      shareParams: params,
                                      sheetConfiguration: config
        ) { (state, _, _, _, _, _) in
            switch state {
            case .success:
                self.showMessage("分享成功")
            case .fail:
                self.showMessage("分享失败")
            default:
                break
            }
        }
    }
}

class ShareVC: BaseVC, ShareVCProtocol {

    @IBOutlet weak var qrCodeIV: UIImageView!
    
    @IBOutlet weak var codeLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "分享易间房APP"
        codeLB.text = DataManager.user()?.stringValue("code")
        qrCodeIV.image = dzy_QrCode(url ?? "", size: 714.0)
    }

    @IBAction func shareAction(_ sender: UIButton) {
        shareBaseFun()
    }
}
