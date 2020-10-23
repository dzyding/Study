//
//  BaseRequest.swift
//  ZAJA
//
//  Created by Nathan_he on 16/9/7.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation
import Alamofire

open class BaseRequest
{
    let signUrls = [BaseURL.PublicTopic,BaseURL.Register,BaseURL.BandOther,BaseURL.FeedBack,BaseURL.ApplyCoach,BaseURL.AddCourse,BaseURL.EditMotionPlan,BaseURL.EditMotion,BaseURL.AddTrainingData,BaseURL.AddBodyData,BaseURL.TopicCommentPublic/*,BaseURL.WechatPayPreOrder,BaseURL.AliPayPreOrder*/]
    
    var method = HTTPMethod.post;
    var dic: [String: String] = [:] //赋值需要在其他修改前面
    var url:String!
    var imagesDic = [String:UIImage]()
    var imagesArr = [UIImage]()
    var headers: HTTPHeaders = [:]
    
    var currentRequest:DataRequest?
    //添加用户信息
    var isUser:Bool = false {
        didSet {
            if isUser {
                let auth = DataManager.userAuth()
                if auth != "" {
                    headers["AUTH"] = auth
                }
            }
        }
    }
    
    var isOther:Bool = false {
        didSet {
            if isOther {
                let auth = DataManager.memberAuth()
                if auth != "" {
                    headers["AUTH"] = auth
                }
            }
        }
    }
    
    // Saas 的 smid
    var isSaasUser: Bool = false {
        didSet {
            if isSaasUser {
                let smid = DataManager.smid()
                if let key = ToolClass.encryptUserId(smid) {
                    headers["m"] = key
                }
            }
        }
    }
    
    // Saas 的 ptid
    var isSaasPt: Bool = false {
        didSet {
            if isSaasPt {
                let smid = DataManager.smid()
                if let key = ToolClass.encryptUserId(smid) {
                    headers["p"] = key
                }
            }
        }
    }
    
    // Saas 的pid (用户预约私教的时候使用)
    open func setPtId(_ ptId: Int) {
        if let key = ToolClass.encryptUserId(ptId) {
            headers["p"] = key
        }
    }
    
    // Saas 的pid 
    open func setPtId(_ ptId: String) {
        headers["p"] = ptId
    }
    
    // Saas 的mid (教练排课的时候使用)
    open func setMemberId(_ mId: String) {
        headers["m"] = mId
    }
    
    // LBS 的健身房 id
    open func setClubId(_ cId: String) {
        headers["c"] = cId
    }
    
    // 设置分享来源
    open func setFpp(_ fpp: String?) {
        fpp.flatMap({
            headers["fpp"] = $0
        })
    }
 
    //他人的Uid
    var otherUid: String? = "" {
        didSet{
            if otherUid != nil && otherUid != "" {
                headers["AUTH"] = otherUid
            }
        }
    }
    
   var location: Bool = false
        {
        didSet{
            if location
            {
                dic["latitude"] = LocationManager.locationManager.latitude
                dic["longitude"] = LocationManager.locationManager.longitude
                dic["city"] = LocationManager.locationManager.city
            }
        }
    }
    
    
    //Page参数
    var page:[Int] = []
        {
        didSet{
            if page.count>0
            {
                dic["pageNum"] = "\(page[0])"
                dic["pageSize"] = "\(page[1])"
            }
        }
    }
    
    //请求数据
    open func start(_ complete:@escaping (Dictionary<String,Any>?,String?)->())
    {
        headerInfo()
        let failUrl = self.url ?? ""
        currentRequest = Alamofire.request(url,  method: method, parameters:dic,encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
   
                    let json = response.result.value as! Dictionary<String,Any>
//                    print(json.description)
                    
                    let status = json["status"] as! Int
                    
                    if(status==0) {
                        complete(json["data"]! as? Dictionary<String, Any>, nil)
                    }else{
                        complete(nil,Config.getErrorMsg(json["msg"] as! String))
                    }
                case .failure(let error):
                    print("url - \(failUrl)\n error - \(error)")
                    complete(nil,"网络异常，请检查您的网络")
                }
        }
    }
    
    //表单上传图片
    open func upload(_ complete:@escaping (Dictionary<String,Any>?,String?)->())
    {
        headerInfo()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key,value) in self.imagesDic
            {
                let imageData = ToolClass.resetSizeOfImageData(source_image: value, maxSize: 100)
                multipartFormData.append(imageData, withName: "\(key)", fileName: "\(key).jpg", mimeType: "image/jpg")
            }
            
            for i in 0..<self.imagesArr.count
            {
                let img = self.imagesArr[i]
                let imageData = ToolClass.resetSizeOfImageData(source_image: img, maxSize: 100)
                multipartFormData.append(imageData, withName: "images", fileName: "image\(i).jpg", mimeType: "image/jpg")
            }
            
            for (key, value) in self.dic {
                multipartFormData.append(value.data(using: String.Encoding.utf8)! , withName: key)
            }
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: method, headers: headers, encodingCompletion:{ encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success:
                        
                        let json = response.result.value as! Dictionary<String,Any>

                        let status = json["status"] as! Int
                        
                        if(status==0)
                        {
                            
                            complete(json["data"]! as? Dictionary<String, Any>, nil)
                        }else{
                            
//                            complete(nil,Config.ErrorMsg[json["msg"] as! String])
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                        complete(nil,"网络异常，请检查您的网络")
                    }
                    
                }
            case .failure(let error):
                print(error)
                complete(nil,"网络异常，请检查您的网络")
            }
        })
    }
    
    //加密头文件
    func headerInfo()
    {
        let now = Date()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = String(Int64(timeInterval * Double(1000)))
        let token = ToolClass.md5(timeStamp + "PPBody")
        let reversed = String(timeStamp.reversed())
        let key = Int64(reversed)! + 5
        
        headers["KEY"] = "\(key)"
        headers["TOKEN"] = "\(token)"
        
//        if signUrls.contains(url)
//        {
//            headers["SIGN"] = signParam()
//        }
        headers["SG"] = signParam()
    }
    
    //加密参数
    func signParam() -> String
    {
        let sortKeys = Array(dic.keys).sorted()
        
        var content = ""
        
        for i in 0..<sortKeys.count
        {
            content.append(sortKeys[i])
            content.append("=")
            content.append(dic[sortKeys[i]]!)
            if i < sortKeys.count - 1
            {
                content.append("&")
            }
        }
        
        return ToolClass.md5("PPBody" + content + "PPBody")
    }
}
