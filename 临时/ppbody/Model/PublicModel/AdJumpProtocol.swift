//
//  AdJumpProtocol.swift
//  PPBody
//
//  Created by edz on 2019/11/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import Foundation

enum AdJumpType: Int {
    case tag = 10
    case longImage = 15
    case url = 20
    case gym = 30
    case groupBuy = 31
    case ptExp = 32
    case goods = 60
}

protocol AdJumpProtocol {
    var actionVC: UINavigationController? {get}
    
    func ad_goTagDetail(_ name: String, animated: Bool)
    func ad_goWebVC(_ url: String,
                 isShare: Bool,
                 animated: Bool,
                 dic: [String : Any]?)
    func ad_goGymDetail(_ gymId: Int, animated: Bool)
    func ad_goGroupBuyDetail(_ gbId: Int, animated: Bool)
    func ad_goPtExpDetail(_ expId: Int, animated: Bool)
    func ad_goGoodsList(_ animated: Bool)
    func ad_goLongImage(_ url: String,
                        title: String?,
                        animated: Bool)
}

extension AdJumpProtocol {
    func ad_goTagDetail(_ name: String, animated: Bool) {
        let vc = TopicTagDetailVC()
        vc.tag = name
        actionVC?.pushViewController(vc, animated: animated)
    }
    
    func ad_goWebVC(_ url: String,
                 isShare: Bool = true,
                 animated: Bool,
                 dic: [String : Any]? = nil) {
        let vc = WKWebVC(url, isShare)
        dic.flatMap({
            vc.title = $0.stringValue("title")
            vc.dataDic = $0
        })
        actionVC?.pushViewController(vc, animated: animated)
    }
    
    func ad_goGymDetail(_ gymId: Int, animated: Bool) {
        guard let cid = ToolClass.encryptUserId(gymId) else {return}
        let vc = LocationGymVC(cid)
        actionVC?.pushViewController(vc, animated: animated)
    }
    
    func ad_goGroupBuyDetail(_ gbId: Int, animated: Bool) {
        let vc = LocationGBDetailVC(gbId)
        actionVC?.pushViewController(vc, animated: animated)
    }
    
    func ad_goPtExpDetail(_ expId: Int, animated: Bool) {
        let vc = LocationPtExpDetailVC(expId)
        actionVC?.pushViewController(vc, animated: animated)
    }
    
    func ad_goGoodsList(_ animated: Bool) {
        let vc = T12GoodsListVC()
        actionVC?.pushViewController(vc, animated: animated)
    }
    
    func ad_goLongImage(_ url: String,
                        title: String?,
                        animated: Bool)
    {
        let vc = LongImageVC(url)
        vc.title = title
        actionVC?.pushViewController(vc, animated: animated)
    }
}
