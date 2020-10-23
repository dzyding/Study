//
//  QRCodeCreateVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import CoreGraphics

class QRCodeCreateVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    private let defaultBrightness: CGFloat = 0.9
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var oldBright: CGFloat = 0

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgQr: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var refreshView: UIView!
    var logoDic = [String: Any]()
    /// 计时
    private var ctime = 0
    
    private lazy var timer = Timer(
        timeInterval: 10.0, repeats: true, block: timerAction
    )
    
    private lazy var btnCommit: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 58, height: 20)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.setTitle("保存", for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.titleLabel?.font = ToolClass.CustomFont(15)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        btn.enableInterval = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的二维码"
        initUI()
        oldBright = UIScreen.main.brightness
        addObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBrightness(defaultBrightness)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setBrightness(oldBright)
        deinitTimer()
    }
    
    deinit {
        print("deinit")
        deinitObservers()
    }
    
    private func initUI() {
        guard let codeString = ToolClass.shareUrl() else {
            ToolClass.showToast("获取二维码数据失败", .Failure)
            return
        }
        
        let qrImg = LBXScanWrapper.createCode(
            codeType: "CIQRCodeGenerator",
            codeString: codeString,
            size: imgQr.bounds.size,
            qrColor: .black,
            bkColor: .white)
        
        if logoDic["head"] as? String == "" {
            imgQr.image = qrImg
        }else {
            imgQr.image = LBXScanWrapper.addImageLogo(
                srcImg: qrImg!,
                logoImg: logoDic["head"] as! UIImage,
                logoSize: CGSize(width: 40, height: 40))
        }
        lblName.text = logoDic["name"] as? String
    }
    
    private func addObserver() {
        registObservers([UIApplication.didBecomeActiveNotification],
                        queue: .main)
        {[unowned self] _ in
            self.setBrightness(self.defaultBrightness)
        }
        
        registObservers([UIApplication.willResignActiveNotification],
                        queue: .main)
        {[unowned self] _ in
            self.fastResumeBrightness()
        }
    }
    
    private func setBrightness(_ value: CGFloat) {
        queue.cancelAllOperations()
        let brightness = UIScreen.main.brightness
        let step: CGFloat = 0.005 * (value > brightness ? 1 : -1)
        let times = Int(abs((value - brightness) / 0.005))
        guard times > 1 else {return}
        (1...times).forEach { (i) in
            queue.addOperation {
                DispatchQueue.main.async {
                    Thread.sleep(forTimeInterval: 1 / 180.0)
                    UIScreen.main.brightness = brightness + CGFloat(i) * step
                }
            }
        }
    }
    
    private func fastResumeBrightness() {
        queue.cancelAllOperations()
        queue.addOperation {
            DispatchQueue.main.async {
                UIScreen.main.brightness = self.defaultBrightness
            }
        }
    }
    
    //    MARK: - deinit
    private func deinitTimer() {
        timer.fire()
        timer.invalidate()
    }
    
    //    MARK: - 定时任务
    private func timerAction(_ timer: Timer) {
        ctime += 10
        // 到时了只是给一个刷新的界面，并不会自动刷新
        if ctime >= 300 {
            refreshView.isHidden = false
        }
    }
    
    //    MARK: - 刷新
    @IBAction func refreshAction(_ sender: UIButton) {
        refreshView.isHidden = true
        ctime = 0
        initUI()
    }
    
    @objc func btnClick() {
        /*
        let vc = QRScanCodeVC();
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        vc.scanStyle = style
        self.navigationController?.pushViewController(vc, animated: true)*/
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        self.view.layer.render(in: ctx!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIImageWriteToSavedPhotosAlbum(newImage!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)) , nil)
        UIGraphicsEndImageContext()
        
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        
        if error != nil {
            ToolClass.showToast("保存至相册失败", .Failure)
            
        } else {
            ToolClass.showToast("保存至相册成功！", .Success)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
