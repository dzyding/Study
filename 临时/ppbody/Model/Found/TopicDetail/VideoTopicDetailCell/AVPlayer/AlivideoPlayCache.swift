//
//  AlivideoPlayCache.swift
//  PPBody
//
//  Created by Nathan_he on 2018/12/7.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import Alamofire


class AlivideoPlayCache: NSObject {
    
    static let cache = AlivideoPlayCache()
    
    var videoCache = [String:Any]()
    
    var getUrlAction:((String,String)->())?
    
    var dataRequest:DataRequest?
    
    static let Notify_LoadVideoUrl = "Notify_LoadVideoUrl"
    
    private func getVideoODUrl(_ vid: String) {
        let request = BaseRequest()
        request.dic = ["vid":vid]
        request.url = BaseURL.GetVideoURL
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            let videoInfo = data!["videoInfo"] as! [String:Any]
            
            let playURL = videoInfo["playURL"] as! String
            
            let requestTime = Date()
            let dic:[String : Any] = ["url":playURL,"time":requestTime]
            
            self.videoCache[vid] = dic
            self.getUrlAction?(vid,playURL)
        }
        dataRequest = request.currentRequest
    }
    
    //获取视频播放地址
    func getUrlFromVid(_ vid: String, complete:@escaping ((String,String)->()))
    {
        self.getUrlAction = complete
        
        if videoCache.keys.contains(where: { (key) -> Bool in
            return key == vid
        })
        {
            let dic = self.videoCache[vid] as! [String:Any]
            let requestTime = dic["time"] as! Date
            let second = Date().timeIntervalSince(requestTime)
            if second/60 > 4 //大于4分钟需要重新获取client
            {
                getVideoODUrl(vid)
            }else{
                let url = dic["url"] as! String
                self.getUrlAction?(vid,url)
  

            }
        }else{
            getVideoODUrl(vid)
        }
    }
    
    func cancelRequest()
    {
        self.dataRequest?.cancel()
    }
}
