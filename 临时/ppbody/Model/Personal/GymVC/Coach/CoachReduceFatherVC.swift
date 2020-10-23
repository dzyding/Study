//
//  CoachReduceFatherVC.swift
//  PPBody
//
//  Created by edz on 2019/5/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceFatherVC: BaseVC {
    
    private var config: [String : Any] = [:]
    
    private var currentWeekVC = CoachReduceVC(.current)
    
    private var nextWeekVC = CoachReduceVC(.next)
    
    var type: CoachReduceTimeType = .current

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = naviRightBtn
        navigationItem.titleView = titleView
        setUI()
    }
    
    private func setUI() {
        addChild(currentWeekVC)
        currentWeekVC.view.frame = view.bounds
        nextWeekVC.view.frame = view.bounds
        view.addSubview(currentWeekVC.view)
        
        currentWeekVC.didMove(toParent: self)
    }
    
    private func updateUI() {
        type = type == .current ? .next : .current
        switch type {
        case .current:
            changeFrom(nextWeekVC, to: currentWeekVC)
        case .next:
            changeFrom(currentWeekVC, to: nextWeekVC)
        }
    }
    
    private func changeFrom(_ oldVC: UIViewController, to newVC: UIViewController)
    {
        addChild(newVC)
        
        transition(from: oldVC, to: newVC, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: {
            self.currentWeekVC.view.frame = self.view.bounds
            self.nextWeekVC.view.frame = self.view.bounds
        }) { (finish) in
            if finish {
                newVC.didMove(toParent: self)
                oldVC.willMove(toParent: nil)
                oldVC.removeFromParent()
            }
        }
    }
    
    @objc private func settingAction() {
        switch type {
        case .current:
            currentWeekVC.settingAction()
        case .next:
            nextWeekVC.settingAction()
        }
    }
    
    //    MARK: - 懒加载
    private lazy var naviRightBtn: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle("预约设置", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = dzy_Font(12)
        btn.addTarget(self, action: #selector(settingAction), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var titleView: CoachReduceTitleView = {
        let view = CoachReduceTitleView
            .initFromNib(CoachReduceTitleView.self)
        view.handler = { [weak self] in
            self?.updateUI()
        }
        return view
    }()
}
