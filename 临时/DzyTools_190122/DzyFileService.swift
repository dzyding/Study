//
//  DzyFileService.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/4/9.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation
import AlamofireImage

let DzyCachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

///单个文件的大小
public func fileSize(path: String) -> UInt64 {
    let manager = FileManager.default
    if manager.fileExists(atPath: path) {
        do {
            let size = try manager.attributesOfItem(atPath: path)[.size]
            if let size = size as? UInt64 {
                return size / 1024 / 1024
            }
        }catch let error {
            dzy_log(error)
        }
    }
    return 0
}

///文件夹的大小
public func folderSize(path: String) -> UInt64 {
    let manager = FileManager.default
    var folderSize: UInt64 = 0
    if manager.fileExists(atPath: path) {
        let childerFiles = manager.subpaths(atPath: path)
        childerFiles?.forEach({ (fileName) in
            let absolutePath = path + "/" + fileName
            folderSize += fileSize(path: absolutePath)
        })
    }
    return folderSize
}

///缓存的大小
public func cacheSize(path: String) -> UInt64 {
    var size = folderSize(path: path)
    let alaSize = AutoPurgingImageCache().memoryUsage / 1024 / 1024
    size += alaSize
    return size
}

///清理缓存
public func clearCache(path: String) {
    let manager = FileManager.default
    if manager.fileExists(atPath: path) {
        let childerFiles = manager.subpaths(atPath: path)
        childerFiles?.forEach({ (fileName) in
            let absolutePath = path + "/" + fileName
            do{
                try manager.removeItem(atPath: absolutePath)
            }catch let error {
                dzy_log(error)
            }
        })
    }
    AutoPurgingImageCache().removeAllImages()
}
