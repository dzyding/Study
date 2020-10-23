//
//  FoundVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import HBDNavigationBar

class FoundVC: ButtonBarPagerTabStripViewController, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    var isReload = false 
    /// 顶部标签按钮右边距
    @IBOutlet weak var btnsRightLC: NSLayoutConstraint!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var notifyLB: UILabel!
    
    @IBAction func searchAction(_ sender: UIButton) {
        let vc = SearchKeyVC()
        vc.hbd_barHidden = true
        let navc = HBDNavigationController(rootViewController: vc)
        navc.modalPresentationStyle = .fullScreen
        tabBarController?.present(navc, animated: true, completion: nil)
    }
    
    @IBAction func messageAction(_ sender: UIButton) {
        let vc = MessageVC()
        vc.hbd_barTintColor = BackgroundColor
        vc.hbd_barShadowHidden = true
        tabBarController?.navigationController?
            .pushViewController(vc, animated: true)
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        TopicTag = nil
        let mask = MaskPublicView.instanceFromNib()
        mask.initUI()
        mask.frame = ScreenBounds
        mask.navigationVC = self.tabBarController?.navigationController
        UIApplication.shared.keyWindow?.addSubview(mask)
        
    }
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemLeftRightMargin = 0
        settings.style.selectedBarBackgroundColor = YellowMainColor
        super.viewDidLoad()
        getMessageNotify()
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = Text1Color
            newCell?.label.textColor = YellowMainColor
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            } else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        
        registObservers([
            Config.Notify_MessageForIM
        ]) { [weak self] (_) in
            //IM消息发送
            DispatchQueue.main.async {
                self?.showMessageNotify()
            }
        }
        
        registObservers([
            Config.Notify_ClearMessage
        ]) { [weak self] (_) in
            self?.getMessageNotify()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMessageNotify()
    }
    
    func showMessageNotify() {
        var noRead = 0
        //获取未读消息
        let messageNotify = DataManager.messageNotify()
        
        if messageNotify == nil {
            noRead += 0
        }else{
            let num = ToolClass.isMessageNoRead(messageNotify!)
            noRead += num
        }
        
        let status = RCIMClient.shared().getConnectionStatus()
        
        if status != RCConnectionStatus.ConnectionStatus_SignUp
        {
            let unreadMsgCount = RCIMClient.shared().getUnreadCount([RCConversationType.ConversationType_PRIVATE.rawValue])
            if unreadMsgCount == 0
            {
                noRead += 0
            }else{
                noRead += Int(unreadMsgCount)
            }
        }
        
        if noRead > 0
        {
            self.notifyLB.text = noRead > 100 ? "..." : "\(noRead)"
            self.notifyLB.isHidden = false
        }else{
            self.notifyLB.isHidden = true
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = HotFoundVC(itemInfo: "热门")
        let child_2 = TribeFoundVC(itemInfo: "部落")
        let child_3 = AttentionFoundVC(itemInfo: "关注")
        
        guard isReload else {
            return [child_1, child_2, child_3]
        }
        
        var childViewControllers = [child_1, child_2, child_3]
        
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
    
    //获取未读消息通知
    func getMessageNotify() {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.MessageNotify
        request.start { (data, error) in
            guard error == nil else {return}
            let msgNum = data!["msgNum"] as! [String:Any]
            DataManager.saveMessageNotify(msgNum)
            self.showMessageNotify()
        }
    }
}
