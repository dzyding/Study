//
//  MotionCacheManager.swift
//  PPBody
//
//  Created by edz on 2019/12/7.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import Kingfisher

enum BaseCacheType {
    case image
    case video
}

class BaseCacheManager: NSObject {
    
    public let fileManager = FileManager.default
    /// 下载单元
    public var session: URLSession?
    /// 下载任务
    public var task: URLSessionDataTask?
    /// 视频二进制流
    public var data: Data?
    /// 缓存时用的 Key
    public var cacheKey: String?
    /// 缓存路径
    public var diskURL: URL!
    /// 最终存储文件夹
    public var package: String {
        return ""
    }
    
    override init() {
        super.init()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        let diskCachePath = PPBodyPathManager.ppbodyCache() + "/" + package
        var isDirectory:ObjCBool = false
        let isExisted = fileManager.fileExists(atPath: diskCachePath, isDirectory: &isDirectory)
        if(!isDirectory.boolValue || !isExisted) {
            do {
                try fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Create disk cache file error:" + error.localizedDescription)
            }
        }
        diskURL = URL(fileURLWithPath: diskCachePath)
    }
    
    //    MARK: - 下载图片
    func downloadImage(_ url: String?, key: String?) {
        guard let url = url,
            let finalUrl = URL(string: url)
        else {
            dzy_log("下载文件失败，url 为空")
            return
        }
        cacheKey = key
        KingfisherManager.shared.downloader.downloadImage(with: finalUrl, options: [.cacheOriginalImage]) { [weak self] (result) in
            switch result {
            case .success(let value):
                self?.storeImgData(value.image)
            case .failure(let error):
                dzy_log(error)
            }
        }
    }
    
    //    MARK: - 保存图片
    func storeImgData(_ image: UIImage) {
        guard let key = cacheKey else {return}
        let path = filePath(key, type: .image)
        if fileManager.createFile(atPath: path,
                                  contents: image.pngData(),
                                  attributes: nil)
        {
            dzy_log("成功")
        }else {
            dzy_log("失败")
        }
    }
    
    //    MARK: - 下载视频
    func downloadVideo(_ url: String?, key: String?) {
        guard let url = url,
            let finalUrl = URL(string: url)
        else {
            dzy_log("下载文件失败，url 为空")
            return
        }
        cacheKey = key
        let request = URLRequest(url: finalUrl, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60)
        task = session?.dataTask(with: request)
        task?.resume()
    }
    
    //    MARK: - 保存视频
    func storeVideoData(_ data:Data?) {
        guard let key = cacheKey else {return}
        let diskPath = filePath(key, type: .video)
        if fileManager.createFile(atPath: diskPath,
                                  contents: data,
                                  attributes: nil)
        {
            dzy_log("成功")
        }else {
            dzy_log("失败")
        }
    }
    
    //    MARK: - 检查是否存在
    func checkExist(_ key: String, type: BaseCacheType) -> Bool {
        return fileManager.fileExists(atPath: filePath(key, type: type))
    }
    
    //    MARK: - 获取 key 对应存储地址
    func filePath(_ key: String, type: BaseCacheType) -> String {
        return diskURL.path + "/" + key.md5() + (type == .video ? ".mp4" : ".png")
    }
}

extension BaseCacheManager: URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    //网络资源下载请求获得响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let httpResponse = dataTask.response as! HTTPURLResponse
        let code = httpResponse.statusCode
        if(code == 200) {
            completionHandler(URLSession.ResponseDisposition.allow)
            data = Data()
        }else {
            completionHandler(URLSession.ResponseDisposition.cancel)
        }
    }
    
    //接收网络资源下载数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data?.append(data)
    }
    
    //网络资源下载请求完毕
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            storeVideoData(data)
        } else {
            print("BaseCacheManager resouce download error:" + error.debugDescription)
        }
    }
    
    //网络缓存数据复用
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        let cachedResponse = proposedResponse
        if dataTask.currentRequest?.cachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData || dataTask.currentRequest?.url?.absoluteString == self.task?.currentRequest?.url?.absoluteString {
            completionHandler(nil)
        }else {
            completionHandler(cachedResponse)
        }
    }
}
