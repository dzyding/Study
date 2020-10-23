//
//  StatisticsVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class StatisticsVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    var isReload = true
    @IBOutlet weak var headIV: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var titleIV: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var tipBtn: UIButton!
    let statisticsMotionVC = StatisticsMotionVC()
    let statisticsBodyVC = StatisticsBodyVC()
    
    var currentVC : UIViewController?
    
    var isOther = false
    
    deinit {
        deinitObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?
            .setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?
            .setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let memberHead = DataManager.getMemberHead()
        if memberHead == nil {
            isOther = false
            self.headIV.setHeadImageUrl(DataManager.getHead())
        }else{
            isOther = true
            self.headIV.setHeadImageUrl(memberHead!)
        }
        if DataManager.isCoach() {
            self.headIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressBookAction)))
        }
        titleLB.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchData)))
        titleIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchData)))
        
        self.addChild(statisticsMotionVC)
        statisticsMotionVC.view.frame = self.containerView.bounds
        statisticsBodyVC.view.frame = self.containerView.bounds
        self.containerView.addSubview(statisticsMotionVC.view)
        self.currentVC = statisticsMotionVC
        statisticsMotionVC.didMove(toParent: self)
        registObservers([
            Config.Notify_ChangeMember
        ], queue: .main) { [weak self] (_) in
            let user = DataManager.memberInfo()
            if user != nil {
                self?.isOther = true
                self?.headIV.setHeadImageUrl(DataManager.getMemberHead()!)
                
            }else{
                self?.isOther = false
                self?.headIV.setHeadImageUrl(DataManager.getHead())
            }
        }
        
        registObservers([
            Config.Notify_ChangeHead
        ], queue: .main) { [weak self] (nofity) in
            //修改头像
            let memberHead = DataManager.getMemberHead()
            if memberHead == nil {
                let userinfo = nofity.userInfo
                self?.headIV.image = userinfo?["head"] as? UIImage
            }
        }
        
        //第一次提示
        if DataManager.firstRegister() == 1 {
            self.tipView.isHidden = false
            self.tipBtn.layer.borderColor = UIColor.white.cgColor
            self.tipBtn.layer.borderWidth = 1
            self.tipBtn.layer.cornerRadius = 4
        }else{
            self.tipView.removeFromSuperview()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dzy_pop()
    }
    
    @IBAction func tipKnowAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.tipView.alpha = 0
        }) { (finish) in
            self.tipView.removeFromSuperview()
        }
    }
    
    @objc func switchData()
    {
        if isReload {
            isReload = false
            if self.titleLB.text == "训练统计"
            {
                changeControllerFromOldController(self.currentVC!, toNewC: statisticsBodyVC)
            }else{
                changeControllerFromOldController(self.currentVC!, toNewC: statisticsMotionVC)
            }
        }

    }
    
    func changeControllerFromOldController(_ oldC: UIViewController, toNewC:UIViewController)
    {
        self.addChild(toNewC)
        
        self.transition(from: oldC, to: toNewC, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: {
            self.statisticsMotionVC.view.frame = self.containerView.bounds
            self.statisticsBodyVC.view.frame = self.containerView.bounds
        }) { (finish) in
            if finish
            {
                toNewC.didMove(toParent: self)
                oldC.willMove(toParent: nil)
                oldC.removeFromParent()
                self.currentVC = toNewC
                
                self.titleLB.text = self.currentVC == self.statisticsBodyVC ? "体态统计" : "训练统计"
            }else{
                self.currentVC = oldC
            }
            self.isReload = true
        }
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        subView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    @objc func addressBookAction()
    {
        if let vc = (parent as? UINavigationController)?
            .viewControllers.first as? PPBodyMainVC
        {
            vc.addressBookAction()
        }
    }
    

}



