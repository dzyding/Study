//
//  QRCodeHelper.swift
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019 selwyn. All rights reserved.
//

import Foundation
import Photos

struct QRCodeHelper {
    
    static weak var vc: QRCodeVC?
    /** 校验是否有相机权限 */
    static func checkCamera(completion: @escaping (_ granted: Bool) -> Void) {
        let videoAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch videoAuthStatus {
        // 已授权
        case .authorized:
            completion(true)
        // 未询问用户是否授权
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                completion(granted)
            })
        // 用户拒绝授权或权限受限
        case .denied, .restricted:
            let alert = UIAlertController(title: "请在”设置-隐私-相机”选项中，允许访问你的相机", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(alertAction)
            vc?.present(alert, animated: true, completion: nil)
            completion(false)
        @unknown default:
            fatalError()
        }
    }
    
    /** 校验是否有相册权限 */
    static func checkAlbum(completion: @escaping (_ granted: Bool) -> Void) {
        let photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthStatus {
        // 已授权
        case .authorized:
            completion(true)
        // 未询问用户是否授权
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                completion(status == .authorized)
            })
        // 用户拒绝授权或权限受限
        case .denied, .restricted:
            let alert = UIAlertController(title: "请在”设置-隐私-相片”选项中，允许访问你的相册", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(alertAction)
            vc?.present(alert, animated: true, completion: nil)
            completion(false)
        @unknown default:
            fatalError()
        }
    }
    
    /** 根据扫描器类型配置支持编码格式 */
    static func metadataObjectTypes(type: QRScannerType) -> [AVMetadataObject.ObjectType] {
        switch type {
        case .qr:
            return [.qr]
        case .bar:
            return [.ean13, .ean8, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417]
        case .both:
            return [.qr, .ean13, .ean8, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417]
        }
    }
    
    /** 根据扫描器类型配置导航栏标题 */
    static func navigationItemTitle(type: QRScannerType) -> String {
        switch type {
        case .qr:
            return "二维码"
        case .bar:
            return "条码"
        case .both:
            return "二维码/条码"
        }
    }
    
    /** 手电筒开关 */
    static func flashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        if device.hasFlash && device.hasTorch {
            try? device.lockForConfiguration()
            device.torchMode = on ? .on:.off
            device.flashMode = on ? .on:.off
            device.unlockForConfiguration()
        }
    }
}
