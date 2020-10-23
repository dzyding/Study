//
//  BaseRequest.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/21.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import UIKit
import Alamofire
import ZKProgressHUD

public let EspecialError = "已知错误"

class BaseRequest: NSObject {
    
    private var noTokenUrls: Set<BaseURL> = [
        .sendVerCode, .checkMobileCode, .mobileLogin,
        .pwdLogin, .regist, .cityList, .setPwd, .uploadPic
    ]
    
    var method = HTTPMethod.post
    var dic: [String : Any] = [:] //赋值需要在其他修改前面
    var url: BaseURL!
    var imagesDic = [String : UIImage]()
    var imagesArr = [UIImage]()
    var headers: HTTPHeaders = [:]
    
    // 完整的 url
    private var wholeUrl: String {
        return HostManager.default.host + "/yjf/api/" + url.rawValue
    }

    var isUser:Bool = false {
        didSet {
            if isUser {
                dic["userId"] = DataManager.getUserId()
            }
        }
    }
    
    var isId: Bool = false {
        didSet {
            if isId {
                dic["id"] = DataManager.getUserId()
            }
        }
    }
    
    //Page参数
    var page:[Int] = [] {
        didSet {
            if page.count>0 {
                dic["pageNum"] = "\(page[0])"
                dic["pageSize"] = "\(page[1])"
            }
        }
    }
    
    open func start(_ complete:@escaping ([String : Any]?, String?)->()) {
        headerInfo()
        Alamofire.request(wholeUrl, method: method, parameters: dic, encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [String : Any] ,
                        let status = json.intValue("status")
                    {
                        if status == 9 {
                            NotificationCenter.default.post(
                                name: PublicConfig.Notice_TokenTimeOut,
                                object: nil, userInfo: nil)
                            complete(nil, nil)
                        }else if let data = json.dicValue("data"),
                            status == 0
                        {
                            complete(data, nil)
                        }else {
                            complete(nil, json.stringValue("msg") ?? "数据错误")
                        }
                    }else {
                        complete(nil, "未知错误")
                    }
                case .failure(let error):
                    complete(nil, error.localizedDescription)
                }
        }
    }
    
    open func dzy_start(_ isShowError: Bool = true, complete:@escaping ([String : Any]?, String?)->()) {
        headerInfo()
        Alamofire.request(wholeUrl, method: method, parameters:dic, encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [String : Any],
                        let status = json.intValue("status")
                    {
                        if status == 0,
                            let data = json.dicValue("data")
                        {
                            complete(data, nil)
                        }else if status == 9 {
                            NotificationCenter.default.post(
                                name: PublicConfig.Notice_TokenTimeOut,
                                object: nil, userInfo: nil)
                            complete(nil, nil)
                        }else if [4, 5, 6, 8].contains(status) {
                            complete(json, EspecialError)
                        }else {
                            dzy_log("请求错误 ----------- \(response.response?.url?.absoluteString ?? "")")
                            let msg = json.stringValue("msg") ?? "数据错误"
                            if isShowError {
                                ZKProgressHUD.showMessage(msg)
                            }
                            complete(nil, msg)
                        }
                    }else {
                        ZKProgressHUD.showMessage("数据错误")
                        complete(nil, nil)
                    }
                case .failure(let error):
                    print(error)
                    ZKProgressHUD.showMessage("网络异常，请检查您的网络")
                    complete(nil, nil)
                }
        }
    }
    
    open func uploadImg(_ complete:@escaping (String?, String?)->()){
        headerInfo()
        guard let data = dic["img"] as? Data else {
            complete(nil, "未获取到图片")
            return
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(
                data,
                withName: "img",
                fileName: "123456.jpg",
                mimeType: "image/jpeg"
            ) //amr/mp3/wmr
        }, to: wholeUrl) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        if let json = (response.result.value as? [String : Any]),
                            let status = json.intValue("status")
                        {
                            if status == 0 {
                                if let imgStr = json.dicValue("data")?.stringValue("sPath") {
                                    complete(imgStr, nil)
                                }else {
                                    complete(nil, nil)
                                }
                            }else if status == 9 {
                                NotificationCenter.default.post(
                                    name: PublicConfig.Notice_TokenTimeOut,
                                    object: nil, userInfo: nil)
                                complete(nil, nil)
                            }else {
                                complete(nil, json.stringValue("msg"))
                            }
                        }else {
                            complete(nil, "未知错误")
                        }
                    case .failure(let error):
                        dzy_log(error)
                        complete(nil, "网络异常，请检查您的网络")
                    }
                })
            case .failure(let error):
                dzy_log(error)
                complete(nil, "网络异常，请检查您的网络")
            }
        }
    }
    
    open func uploadMp3(_ complete:@escaping ([String : Any]?, String?)->()){
        headerInfo()
        guard let data = dic["audio"] as? Data else {
            complete(nil, "未获取到图片")
            return
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: "audio", fileName: "123456.mp3", mimeType: "amr/mp3/wmr")
        }, to: wholeUrl) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        if let json = response.result.value as? [String : Any],
                            let status = json.intValue("status")
                        {
                            if status == 0 {
                                complete(json.dicValue("data"), nil)
                            }else if status == 9 {
                                NotificationCenter.default.post(
                                    name: PublicConfig.Notice_TokenTimeOut,
                                    object: nil, userInfo: nil)
                                complete(nil, nil)
                            } else {
                                complete(nil, json.stringValue("msg"))
                            }
                        }
                    case .failure(let error):
                        dzy_log(error)
                        ZKProgressHUD.showMessage("网络异常，请检查您的网络")
                        complete(nil, nil)
                    }
                })
            case .failure(let error):
                dzy_log(error)
                complete(nil, "网络异常，请检查您的网络")
            }
        }
    }
    
    //加密头文件
    func headerInfo() {
        if !noTokenUrls.contains(url),
            let token = DataManager.user()?.stringValue("token")
        {
            headers = ["TOKEN" : token]
        }
    }
}
