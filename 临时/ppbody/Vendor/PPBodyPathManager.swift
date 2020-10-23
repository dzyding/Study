//
//  PPBodyPathManager.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class PPBodyPathManager{
 
    static func rootPath()->String
    {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    static func cachePath()->String{
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    
    static func tempPath()->String{
        return NSTemporaryDirectory()
    }
    
    static func ppbodyRootPath()->String{
        return self.rootPath() + "/" + "com.qx1024.ppbody"
    }
    
    static func ppbodyCache()->String{
        return self.cachePath() + "/" + "com.qx1024.ppbody"
    }
    
    static func compositionRootDir() -> String{
        return self.rootPath() + "/" + "composition"
    }
    
    static func clearDir(_ dirPath:String)
    {
        do {
            let fm = FileManager.default
            try fm.removeItem(atPath: dirPath)
            fm.createFile(atPath: dirPath, contents: nil, attributes: nil)
        }
        catch _ as NSError {
            print("error")
        }
    }
    
    static func uuidString()->String{
        return UUID().uuidString
    }
    
    static func createRecrodDir() -> String{
        return self.ppbodyRootPath() + "/" + "record"
    }
    
    static func createSelectDir() -> String{
        return self.ppbodyRootPath() + "/" + "select"
    }
    
    static func createEditDir() -> String{
        return self.ppbodyRootPath() + "/" + "edit"
    }
    
    static func getEditMusic() -> String{
        return self.createEditDir() + "/" + "music" + ".mov"
    }
    
    static func getVideoDownloadPath() -> String
    {
        let videoCache = self.ppbodyCache() + "/" + "video"
        
        if !FileManager.default.fileExists(atPath: videoCache)
        {
            try? FileManager.default.createDirectory(atPath: videoCache, withIntermediateDirectories: true, attributes: nil)
        }
        return videoCache
    }
    
    static func getVideoOutPut()->String{
        //删除缓存
        let taskPath = self.compositionRootDir()
        if !FileManager.default.fileExists(atPath: taskPath)
        {
            try? FileManager.default.createDirectory(atPath: taskPath, withIntermediateDirectories: true, attributes: nil)
        }
        return taskPath + "/" + uuidString() + ".mp4"
    }
    
    static func resetVideoOutPut(){
        let taskPath = self.compositionRootDir()
        let fileManager = FileManager.default
        
        if FileManager.default.fileExists(atPath: taskPath)
        {
            try! fileManager.removeItem(atPath: taskPath)

        }
        try! fileManager.createDirectory(atPath: taskPath, withIntermediateDirectories: true,
                                         attributes: nil)
    }
}
