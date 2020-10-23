//
//  AdvertiseCacheManager.swift
//  PPBody
//
//  Created by edz on 2019/1/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import Kingfisher

enum AdFileType {
    case img
    case video
}

class AdCacheManager: NSObject {
    
    static let `default` = AdCacheManager()
    
    let fileManager = FileManager.default
    /// 下载单元
    fileprivate var session: URLSession?
    /// 下载任务
    fileprivate var task: URLSessionDataTask?
    /// 视频二进制流
    fileprivate var data: Data?
    /// 视频缓存 key
    fileprivate var cacheKey: String?
    /// 缓存路径
    fileprivate var diskURL: URL!
    
    var urlData: [String : Any] = [:]
    
    var deletes = [Int]()
    
    override init() {
        super.init()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        let diskCachePath = PPBodyPathManager.ppbodyCache() + "/splashCache"
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
    
    //    MARK: - 下载文件
    func download(_ url: String?, type: AdFileType) {
        guard let url = url else {
            dzy_log("下载文件失败，url 为空")
            return
        }
        let md5String = url.md5()
        if !checkExist(url, type: type),
            let finalUrl = URL(string: url)
        {
            var datas = DataManager.splashs() ?? []
            datas.append(urlData)
            DataManager.saveSplash(datas)
            
            cacheKey = md5String
            switch type {
            case .img:
                KingfisherManager.shared.downloader.downloadImage(with: finalUrl, options: [.cacheOriginalImage]) { [weak self] (image, error, _, _) in
                    if let image = image {
                        self?.storeImgData(image)
                    }else {
                        dzy_log("下载图片失败")
                    }
                }
            case .video:
                let request = URLRequest(url: finalUrl, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60)
                task = session?.dataTask(with: request)
                task?.resume()
            }
        }else {
            urlData = [:]
            dzy_log("文件已存在")
        }
    }
    
    //    MARK: - 移除删除缓存
    func removeDeletesFromServer()
    {
        if var datas = DataManager.splashs() {
            var i = 0
            while i < datas.count {
                let urldata = datas[i]
                if checkDate(urldata) {
                    datas.remove(at: i)
                    deleteFile(urldata)
                }else {
                    i += 1
                }
            }
            DataManager.saveSplash(datas)
        }
    }
    
    //    MARK: - 读取当前缓存文件
    func loadAndPlay() {
        if let datas = DataManager.splashs() {
            play(datas)
        }
    }
    
    //    MARK: - 随机播放
    func play(_ datas: [[String : Any]]) {
        if datas.count == 0 {return}
        let num = datas.count > 1 ? ToolClass.randomCustom(min: 0, max: datas.count - 1) : 0
        let urldata = datas[num]
        if let video = urldata.stringValue("video"), video.count > 0 {// 视频
            playVideo(video, urlData: urldata)
        }else if let cover = urldata.stringValue("cover"), cover.count > 0 {
            playImage(cover, urlData: urldata)
        }
    }
    
    //    MARK: - 播放视频
    func playVideo(_ url: String, urlData: [String : Any]) {
//        FIXME: 这里的url似乎需要处理一下 getFilePath(url, type: .video)
        AdvertiseView.showVideo(url, urlData: urlData)
    }
    
    //    MARK: - 显示图片
    func playImage(_ url: String, urlData: [String : Any]) {
        let url = URL(fileURLWithPath: getFilePath(url, type: .img))
        do {
            let imgData = try Data(contentsOf: url)
            if let img = UIImage(data: imgData) {
                AdvertiseView.showImage(img, urlData: urlData)
            }
        }catch{
            dzy_log("获取图片失败")
        }
    }
    
    
    fileprivate func getFilePath(_ url: String, type: AdFileType) -> String {
        return diskURL.path + "/" + url.md5() + (type == .video ? ".mp4" : ".png")
    }
    
    //    MARK: - 删除文件
    func deleteFile(_ urldata: [String : Any]) {
        var filePath: String?
        if let video = urldata.stringValue("video"), video.count > 0 {// 视频
            filePath = getFilePath(video, type: .video)
        }else if let cover = urldata.stringValue("cover"), cover.count > 0 {
            filePath = getFilePath(cover, type: .img)
        }
        do {
            try fileManager.removeItem(atPath: filePath ?? "")
        }catch {
            dzy_log("删除 \(filePath ?? "") 失败")
        }
    }
    
    //    MARK: - 检查是否过期，过期了则删除
    func checkDate(_ urlData: [String : Any]) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let current = Date().timeIntervalSince1970
        
        let splashId = urlData.intValue("id")
        if let end = formatter.date(from: urlData.stringValue("endTime") ?? "")?.timeIntervalSince1970,
            current - end >= 0 || self.deletes.contains(splashId!)
        {
            return true
        }else {
            return false
        }
    }
    
    //    MARK: - 检查是否存在
    func checkExist(_ fileName: String, type: AdFileType) -> Bool {
        return fileManager.fileExists(atPath: getFilePath(fileName, type: type))
    }
    
    //    MARK: - 保存图片
    func storeImgData(_ image: UIImage) {
        if let path = diskCachePathForKey(cacheKey ?? "", exten: "png") {
            if fileManager.createFile(atPath: path, contents: image.pngData(), attributes: nil) {
                dzy_log("成功")
            }else {
                dzy_log("失败")
            }
        }else {
            dzy_log("转换png二进制失败")
        }
    }
    
    //MARK: - 根据key将数据存在本地
    func storeDataToDiskCache(data:Data?, key:String)  {
        if let diskPath = diskCachePathForKey(key, exten: "mp4") {
            if fileManager.createFile(atPath: diskPath, contents: data, attributes: nil){
                dzy_log("成功")
            }else {
                dzy_log("失败")
            }
        }else {
            dzy_log("存储文件失败")
        }
    }
    
    //获取key值对应的磁盘缓存文件路径，文件路径包含指定扩展名
    func diskCachePathForKey(_ fileName:String, exten:String?) -> String? {
        var cachePathForKey = diskURL?.appendingPathComponent(fileName).path
        if let exten = exten {
            cachePathForKey = cachePathForKey! + "." + exten
        }
        return cachePathForKey
    }
    
    //    MARK: - 根据接口返回数据，进行相关操作
    func dataOperation(_ urlData: [String : Any]) {
        self.urlData = urlData
        if let video = urlData.stringValue("video"), video.count > 0 {// 视频
            download(video, type: .video)
        }else if let cover = urlData.stringValue("cover"), cover.count > 0 {
            download(cover, type: .img)
        }else {
            self.urlData = [:]
        }
    }
    
    //    MARK: - 网络请求
    func splashApi() {
        let requset = BaseRequest()
        requset.url = BaseURL.Splash
        requset.start { (urlData, error) in
            guard error == nil else {return}
            if let splash = urlData?["splash"] as? [String : Any] {
                self.dataOperation(splash)
                self.deletes = urlData?["deletes"] as! [Int]
                self.removeDeletesFromServer()
            }
        }
    }
}

extension AdCacheManager: URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
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
            storeDataToDiskCache(data: data, key: cacheKey ?? "")
        } else {
            print("AdManager resouce download error:" + error.debugDescription)
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
