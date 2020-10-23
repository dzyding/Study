//
//  QRScanCodeVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol QRScanCodeDelegate:NSObjectProtocol {
    func qrScanCode(_ code: String)
}

class QRScanCodeVC: LBXScanViewController {

    /**
     @brief  扫码区域上方提示文字
     */
    var topTitle:UILabel?
    
    /**
     @brief  闪关灯开启状态
     */
    var isOpenedFlash:Bool = false
    
    //底部显示的功能项
    var bottomItemsView:UIView?
    
    //闪光灯
    var btnFlash:UIButton = UIButton()
    
    weak var delegate:QRScanCodeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "扫一扫"
        
        //需要识别后的图像
        setNeedCodeImage(needCodeImg: true)
        
        //框向上移动10个像素
        scanStyle?.centerUpOffset += 10
        
        let rightBtn = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(photoAction))
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawBottomItems()
    }
    
    @objc func photoAction() {
        openPhotoAlbum()
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        for result:LBXScanResult in arrayResult {
            if let str = result.strScanned {
                dzy_log(str)
                
                if str.hasPrefix("R"),
                    str.hasSuffix("P") {
                    NotificationCenter.default.post(
                        name: Config.Notify_ReduceCourse,
                        object: nil,
                        userInfo: ["code" : str]
                    )
                }else if str.hasPrefix("uid:"){
                    //他人主页
                    let vc = PersonalPageVC()
                    vc.uid = str.replacingOccurrences(of: "uid:", with: "")
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if str.hasPrefix("invite:")
                {
                    delegate?.qrScanCode(str.replacingOccurrences(of: "invite:", with: ""))
                    navigationController?.popViewController(animated: true)
                }else if str.hasPrefix(ToolClass.baseQrUrl) {
                    guard let result = ToolClass.decryptShareUrl(str) else {return}
                    let now = Date().timeIntervalSince1970 * 1000
                    if now - result.1 >= 300 * 1000 {
                        ToolClass.showToast("二维码已过期", .Failure)
                    }else {
                        let vc = PersonalPageVC()
                        vc.uid = ToolClass.encryptUserId(result.0)
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }else {
                    let alert = UIAlertController(title: "无效结果", message: "扫描结果为：" + str, preferredStyle: .alert)
                    let sure = UIAlertAction(title: "确定", style: .default, handler: nil)
                    alert.addAction(sure)
                    self.navigationController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func drawBottomItems()
    {
        if (bottomItemsView != nil) {
            
            return;
        }
        
        let yMax = self.view.frame.maxY - self.view.frame.minY
        
        bottomItemsView = UIView(frame:CGRect(x: 0.0, y: yMax-100,width: self.view.frame.size.width, height: 100 ) )
        
        
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view .addSubview(bottomItemsView!)
        
        
        let size = CGSize(width: 65, height: 87);
        
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(x: bottomItemsView!.frame.width/2, y: bottomItemsView!.frame.height/2)
        btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControl.State.normal)
        btnFlash.addTarget(self, action: #selector(openOrCloseFlash), for: UIControl.Event.touchUpInside)
        
        bottomItemsView?.addSubview(btnFlash)
        
        self.view .addSubview(bottomItemsView!)
        
    }
    
    //开关闪光灯
    @objc func openOrCloseFlash()
    {
        scanObj?.changeTorch();
        
        isOpenedFlash = !isOpenedFlash
        
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), for:UIControl.State.normal)
        }
        else
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControl.State.normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
