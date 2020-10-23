//
//  NewTrainRecordVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MotionTrainingSpaceVC: BaseVC {
    
    var isReload: Bool = true
    @IBOutlet weak var containerView: UIView!
    
    var titleView : CommonTitleView = {
        let view = Bundle.main.loadNibNamed("CommonTitleView", owner: self, options: nil)?.first as! CommonTitleView
        view.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: 44.0)
        return view
    }()
    
    lazy var headBar: UIImageView = {
        let headBtn = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        headBtn.layer.cornerRadius = 15
        headBtn.layer.masksToBounds = true
        headBtn.isUserInteractionEnabled = true
//        headBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressBookAction)))
        return headBtn
    }()
    
    let motionVC = MotionLibraryVC()
    let privateVC = PrivateTrainVC()
    let userPrivateVC = UserPrivateTrainVC()//用户端
    
    var isOther = false
    
    var currentVC : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //判断是否是学员
        if DataManager.memberInfo() != nil
        {
            isOther = true
            addRightBar()
        }
        
        self.titleView.btnTitle.addTarget(self, action: #selector(btnTitleClick), for: .touchUpInside)
        self.navigationItem.titleView = self.titleView
        self.addChild(motionVC)
        
        motionVC.view.frame = self.containerView.bounds
        privateVC.view.frame = self.containerView.bounds
        userPrivateVC.view.frame = self.containerView.bounds
        
        self.containerView.addSubview(motionVC.view)
        
        self.currentVC = motionVC
        
        motionVC.didMove(toParent: self)
        
    }
    
    func addRightBar()
    {
        let rightview = UIView(frame: self.headBar.bounds)
        rightview.addSubview(self.headBar)
        let rightbar = UIBarButtonItem(customView: rightview)
        self.headBar.setHeadImageUrl(DataManager.getMemberHead()!)
        self.navigationItem.rightBarButtonItem = rightbar
    }
    
    @objc func btnTitleClick(btn: UIButton) {
        if isReload {
            isReload = false
            switchData()
        }
    }
    
    func switchData() {
        if self.titleView.btnTitle.titleLabel?.text == "系统训练 " {
            if DataManager.isCoach() {
                changeControllerFromOldController(self.currentVC!, toNewC: privateVC)
            }
            else {
                changeControllerFromOldController(self.currentVC!, toNewC: userPrivateVC)
            }
        }else{
            changeControllerFromOldController(self.currentVC!, toNewC: motionVC)
        }
    }
    
    func changeControllerFromOldController(_ oldC: UIViewController, toNewC:UIViewController)
    {
        
        
        if !self.children.contains(toNewC) {
            self.addChild(toNewC)
        }
        
        self.transition(from: oldC, to: toNewC, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: {
            self.motionVC.view.frame = self.containerView.bounds
            if DataManager.isCoach() {
                self.privateVC.view.frame = self.containerView.bounds
            }
            else {
                self.userPrivateVC.view.frame = self.containerView.bounds
            }
        }) { (finish) in
            if finish
            {
                toNewC.didMove(toParent: self)
                oldC.willMove(toParent: nil)
                oldC.removeFromParent()
                self.currentVC = toNewC
                let titleStr = self.currentVC == self.motionVC ? "系统训练 " : "私教训练 "
                self.titleView.btnTitle.setTitle(titleStr, for: .normal)
                
            }else{
                self.currentVC = oldC
            }
            self.isReload = true
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
