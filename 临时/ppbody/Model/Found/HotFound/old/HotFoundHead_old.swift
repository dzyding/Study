//
//  HotFoundHead_old.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class HotFoundHead_old: UICollectionReusableView {
    // 不包含 Banner 时的高度
    static let normalH: CGFloat = 265.0
    // banner 宽度
    static let bannerW: CGFloat = ScreenWidth - 32.0
    
    @IBOutlet weak var stackview: UIStackView!
    // tags
    var listData:[[String : Any]]?
    // banner
    var bannerDatas: [[String : Any]] = []
    // 没有banner时的处理
    var noBannerHandler: (()->())?
    
    override func awakeFromNib() {
        getTagBanner()
    }
    
//    MARK: - api
    func getTagBanner() {
        let request = BaseRequest()
        request.url = BaseURL.TagBanner
        request.start { [unowned self] (data, error) in
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let list = data?["tags"] as? [[String : Any]], list.count > 0 {
                self.listData = list
                
                for i in 0..<list.count{
                    let tag = TagView_old.instanceFromNib()
                    tag.setData(list[i])
                    tag.tag = i
                    tag.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapTagView(_:))))
                    self.stackview.addArrangedSubview(tag)
                }
            }
            if let bData = data?["banner"] as? [[String : Any]], bData.count > 0 {
                self.bannerDatas = bData
                self.setBanner(bData)
            }else {
                self.noBannerHandler?()
            }
        }
    }
    
    private func adApi(_ bid: Int) {
        let request = BaseRequest()
        request.url = BaseURL.AdSt
        request.dic = [
            "obId" : "\(bid)",
            "type" : "\(20)"
        ]
        request.start { (data, error) in
            
        }
    }
    
//    MARK: - 更新 UI
    func setBanner(_ data: [[String : Any]]) {
        let frame = CGRect(x: 16,
                           y: 0,
                           width: HotFoundHead_old.bannerW,
                           height: HotFoundHead_old.bannerW / 2.0)
        let adView = DzyAdView(frame, pageType: .rect)
        adView.updateUI(data.compactMap({$0["cover"] as? String}))
        adView.handler = { [weak self] index in
            self?.tapBanner(index)
        }
        adView.layer.cornerRadius = 4
        adView.clipsToBounds = true
        addSubview(adView)
    }
    
    @objc func tapTagView(_ tap: UITapGestureRecognizer) {
        let tag = tap.view?.tag
        let dic = listData![tag!]
        if let name = dic.stringValue("name") {
            ad_goTagDetail(name, animated: true)
        }
    }
    
    func tapBanner(_ index: Int) {
        let dict = bannerDatas[index]
        guard let value = dict.intValue("type"),
            let type = AdJumpType(rawValue: value)
        else {return}
        dict.intValue("id").flatMap({
            adApi($0)
        })
        switch type {
        case .tag:
            if let tagName = dict.stringValue("tag") {
                ad_goTagDetail(tagName, animated: true)
            }
        case .url:
            if var url = dict.stringValue("url") {
                let auth = DataManager.userAuth()
                if url.contains("?") {
                    url = (auth != "") ? (url + "&uid=\(auth)") : url
                }else {
                    url = (auth != "") ? (url + "?uid=\(auth)") : url
                }
                ad_goWebVC(url, animated: true, dic: dict)
            }
        case .groupBuy:
            dict.intValue("obId").flatMap({
                ad_goGroupBuyDetail($0, animated: true)
            })
        case .ptExp:
            dict.intValue("obId").flatMap({
                ad_goPtExpDetail($0, animated: true)
            })
        case .gym:
            dict.intValue("obId").flatMap({
                ad_goGymDetail($0, animated: true)
            })
        case .longImage:
            dict.stringValue("url").flatMap({
                ad_goLongImage($0,
                               title: dict.stringValue("title"),
                               animated: true)
            })
        case .goods:
            ad_goGoodsList(true)
        }
    }

    @IBAction func moreAction(_ sender: UIButton) {
        let vc = TopicTagVC(.list)
        parentVC?.tabBarController?.dzy_push(vc)
    }
    
}

extension HotFoundHead_old: AdJumpProtocol {
    var actionVC: UINavigationController? {
        return parentVC?.tabBarController?.navigationController
    }
}
