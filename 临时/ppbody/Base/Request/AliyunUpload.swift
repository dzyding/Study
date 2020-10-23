//
//  AliyunUpload.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

enum UploadCatalog{
    case Head
    case Topic
    case Coach
    case Plan
    case Motion
    case Course
    case UserCover
    ///  投诉
    case Report
    /// 评论
    case Evaluate
}

class AliyunUpload: NSObject {
    
    static let upload = AliyunUpload()
    //PPbody
    let OSS_ENDPOINT: String = "http://oss-cn-shenzhen.aliyuncs.com"
    var OSS_BUCKET: String = "ppbody"
    
    var complete: ((Double)->())?
    
    var mClient: OSSClient?
    var tokenTime:Date?
    var token : OSSFederationToken?
    var ossAsyncTasks = [OSSTask<AnyObject>]()
    
    var needUpdate = false
    
    //获取upload client
    func getClient() -> OSSClient
    {
        let provider = getProvider()
        if needUpdate || mClient == nil
        {
            let conf = OSSClientConfiguration()
            conf.maxRetryCount = 9
            conf.timeoutIntervalForRequest = 30
            conf.timeoutIntervalForResource = 24*60*60
            mClient = OSSClient(endpoint: OSS_ENDPOINT, credentialProvider: provider, clientConfiguration: conf)
            
            needUpdate = false
        }
        
        return mClient!
    }
    
    
    func getOSSFederationToken(_ complete: @escaping (OSSFederationToken)->())
    {
        if tokenTime == nil {
            
            getStsToken({ (token) in
                self.token = token
                self.tokenTime = Date()
                self.needUpdate = true
                complete(self.token!)
            })
        }else{
            let second = Date().timeIntervalSince(tokenTime!)
            if second/60 > 45 //大于45分钟需要重新获取client
            {
                getStsToken({ (token) in
                    self.token = token
                    self.tokenTime = Date()
                    self.needUpdate = true
                    complete(self.token!)
                })
            } else{
                complete(self.token!)
            }
        }
  
    }
    
    func getStsToken(_ complete: @escaping (OSSFederationToken)->())
    {
        token = OSSFederationToken()
        
        let request = BaseRequest()
        request.url = BaseURL.UploadSts
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            
            let dic = data!["sts"] as! [String:Any]
            
            self.token?.tAccessKey = dic["AccessKeyId"] as! String
            self.token?.tSecretKey = dic["AccessKeySecret"] as! String
            self.token?.tToken = dic["SecurityToken"] as! String
            self.token?.expirationTimeInGMTFormat = dic["Expiration"] as? String
            
            complete(self.token!)
            
        }

    }
    
    func getProvider() -> OSSAuthCredentialProvider
    {
         
        return  OSSAuthCredentialProvider { () -> OSSFederationToken? in
            let tcs = OSSTaskCompletionSource<AnyObject>()
             self.getOSSFederationToken({ (token) in
                tcs.setResult(token)
            })
            
            tcs.task.waitUntilFinished()
            if (tcs.task.error != nil)
            {
                return  nil
            }else{
                return tcs.task.result as? OSSFederationToken
            }
        }
    }
    
    
    func putObject(client:OSSClient, data: Data, path: String, complete: ((Double)->())?)  {
        let request = OSSPutObjectRequest()
        request.uploadingData = data
        request.bucketName = OSS_BUCKET
        request.objectKey = path
        request.uploadProgress = { (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
//            print("bytesSent:\(bytesSent),totalBytesSent:\(totalBytesSent),totalBytesExpectedToSend:\(totalBytesExpectedToSend)");
            
            DispatchQueue.main.async {
                complete?(Double(bytesSent)/Double(totalBytesExpectedToSend))
            }
            
        };
        
        let task = client.putObject(request)
        
        task.continue({ (task) -> Any? in
            if (task.error != nil) {
                print("上传OSS失败")
                let error: NSError = (task.error)! as NSError
                print(error.description)
                
                complete?(-1)
            }else
            {
                complete?(1)
                print("上传OSS成功")
            }
            return nil
        })
        
    }
    
    func putVideo(file: String, path: String, complete: ((Double)->())?)
    {
        let request = OSSPutObjectRequest()
        request.uploadingFileURL = URL(fileURLWithPath: file)
        request.bucketName = OSS_BUCKET
        request.objectKey = path
        request.uploadProgress = { (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            //            print("bytesSent:\(bytesSent),totalBytesSent:\(totalBytesSent),totalBytesExpectedToSend:\(totalBytesExpectedToSend)");
            DispatchQueue.main.async {
                complete?(Double(bytesSent)/Double(totalBytesExpectedToSend))
            }
            
        };
        
        let task = getClient().putObject(request)
        
        task.continue({ (task) -> Any? in
            if (task.error != nil) {
                print("上传OSS失败")
                let error: NSError = (task.error)! as NSError
                print(error.description)
                
                complete?(-1)
            }else
            {
                print("上传OSS成功")
            }
            return nil
        })
        
    }
    
    func cancelTasks()
    {
        for task in ossAsyncTasks
        {
            if !task.isCompleted
            {
            }
        }
    }
    
    //下载object
    func downloadMusic(_ object: String, complete: ((String?)->())?)
    {
        let path = NSTemporaryDirectory() + object
        
        if FileManager.default.fileExists(atPath: path)
        {
            complete?(path)
            return
        }
        
        let request = OSSGetObjectRequest()
        request.bucketName = OSS_BUCKET
        request.objectKey = object
        request.downloadProgress = {(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> () in
            print("bytesWritten:\(bytesWritten),totalBytesWritten:\(totalBytesWritten),totalBytesExpectedToWrite:\(totalBytesExpectedToWrite)");
        }
        request.downloadToFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + object)
        let client = getClient()

        let task = client.getObject(request)
        task.continue({ (task) -> Any? in
            if (task.error != nil) {
                print("下载 Object 失败")
                let error: NSError = (task.error)! as NSError
                print(error.description)
                complete?(nil)
            }else
            {
                complete?(path)
                print("下载 Object 成功")
            }
            return nil
        })
    }
    
    func uploadAliOSS(_ imgArr: [UIImage],
                      type: UploadCatalog,
                      _ complete:@escaping (Double)->()) ->[String]
    {
        OSS_BUCKET = "ppbody"
        var path = ""
        switch type {
        case .Head:
            path = "head/"
        case .Topic:
            path = "topic/"
        case .Coach:
            path = "coach/"
        case .Plan:
            path = "plan/"
        case .Motion:
            path = "motion/"
        case .Course:
            path = "course/"
        case .UserCover:
            path = "user/cover/"
        case .Report:
            path = "accusation/"
        case .Evaluate: // 评论是传到 ppsaas
            OSS_BUCKET = "ppsaas"
            path = "club/comment/"
        }
        var imgList = [String]()
        
        let client = getClient()
        for img in imgArr {
            let resizeData = ToolClass.resetSizeOfImageData(source_image: img, maxSize: 100)
            let objectName = path + ToolClass.md5(resizeData) + ".jpg"
            
            imgList.append(objectName)
            self.putObject(client:client, data: resizeData, path: objectName, complete: complete)
        }
        
        return imgList
    }
}
