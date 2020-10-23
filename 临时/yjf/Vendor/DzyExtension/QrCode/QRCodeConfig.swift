//
//  QRCodeConfig.swift
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019 selwyn. All rights reserved.
//

import UIKit

enum QRScannerType {
    case qr
    case bar
    case both
}

enum QRScannerArea {
    case def        // 扫描框
    case fullscreen // 全屏
}

struct QRCodeConfig {
    /// 扫描器类型 默认支持二维码以及条码
    var scannerType: QRScannerType = .both
    /// 扫描区域
    var scannerArea: QRScannerArea = .def
    
    /// 棱角颜色 默认RGB色值 r:63 g:187 b:54 a:1.0
    var scannerCornerColor = dzy_HexColor(0xFD7E25)
    
    /// 边框颜色 默认白色
    var scannerBorderColor: UIColor = .white
    
    /// 指示器风格
    var indicatorViewStyle: UIActivityIndicatorView.Style = .whiteLarge
}
