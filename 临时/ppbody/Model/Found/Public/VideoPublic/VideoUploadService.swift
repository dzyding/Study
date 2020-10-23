//
//  VideoUploadService.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

//FIXME: - AliyunIExporterCallback AliyunPublishManager
class VideoUploadService: NSObject {
    
//    weak var exportCallback:AliyunIExporterCallback?
    weak var uploadCallback:VODUploadSVideoClientDelegate?
    
    static let service = VideoUploadService()
    
//    lazy var manager : AliyunPublishManager = {
//        let manager = AliyunPublishManager()
//        manager.exportCallback = self
////        manager.uploadCallback = self
//        return manager
//    }()
    
    lazy var vodUploadClient : VODUploadSVideoClient = {
        let client = VODUploadSVideoClient()
        client.delegate = self
        client.transcode = true
        return client
    }()
    
    /*
    func setTailWaterMark(_ imagePath:String, frame: CGRect, duration:CGFloat)
    {
        let effect = AliyunEffectImage()
        effect.path = imagePath
        effect.frame = frame
        manager.setTailWaterMark(effect)
    }
    
    func exportWithTaskPath(_ taskPath:String, outputPath:String)
    {
        manager.export(withTaskPath: taskPath, outputPath: outputPath)
    }
    
    func cancelExport()
    {
        manager.cancelExport()
    }
    
    
    func uploadWithImagePath(_ imagePath:String, svideoInfo:AliyunUploadSVideoInfo, accessKeyId: String, accessKeySecret: String, accessToken: String)
    {
        manager.upload(withImagePath: imagePath, svideoInfo: svideoInfo, accessKeyId: accessKeyId, accessKeySecret: accessKeySecret, accessToken: accessToken)
    }
     */
    
    func uploadWithVideoPath(_ videoPath:String, imagePath:String, svideoInfo:VodSVideoInfo, accessKeyId: String, accessKeySecret: String, accessToken: String)
    {
        vodUploadClient.upload(withVideoPath: videoPath, imagePath: imagePath, svideoInfo: svideoInfo, accessKeyId: accessKeyId, accessKeySecret: accessKeySecret, accessToken: accessToken)
    }
    
    /*
    func refreshWithAccessKeyId(_ accessKeyId: String, accessKeySecret: String, accessToken: String, expireTime: String)
    {
        manager.refresh(withAccessKeyId: accessKeyId, accessKeySecret: accessKeySecret, accessToken: accessToken, expireTime: expireTime)
    }
    
    func cancelUpload()
    {
        manager.cancelUpload()
    }
    */
}

extension VideoUploadService:/*AliyunIExporterCallback,*/ VODUploadSVideoClientDelegate
{
 
    /*
    func exporterDidStart() {
        exportCallback?.exporterDidStart()
    }
    
    func exporterDidEnd(_ outputPath: String!) {
        exportCallback?.exporterDidEnd(outputPath)
    }
    
    func exporterDidCancel() {
        exportCallback?.exporterDidCancel()
    }
    
    func exportProgress(_ progress: Float) {
        exportCallback?.exportProgress(progress)
    }
    
    func exportError(_ errorCode: Int32) {
        exportCallback?.exportError(errorCode)
    }
    */
    
    func uploadSuccess(with result: VodSVideoUploadResult!) {
        uploadCallback?.uploadSuccess(with: result)
    }
    
    func uploadFailed(withCode code: String!, message: String!) {
        uploadCallback?.uploadFailed(withCode: code, message: message)
    }
    
    func uploadProgress(withUploadedSize uploadedSize: Int64, totalSize: Int64) {
        uploadCallback?.uploadProgress(withUploadedSize: uploadedSize, totalSize: totalSize)
    }
    
    func uploadTokenExpired() {
        uploadCallback?.uploadTokenExpired()
    }
    
    func uploadRetry() {
        uploadCallback?.uploadRetry()
    }
    
    func uploadRetryResume() {
        uploadCallback?.uploadRetryResume()
    }
    
    
    
}
