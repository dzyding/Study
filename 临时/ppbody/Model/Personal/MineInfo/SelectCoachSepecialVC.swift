//
//  SelectCoachSepecialVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol SelectCoachSepecialDelegate:NSObjectProtocol {
    func selectTags(_ tags: String)
}

class SelectCoachSepecialVC: BaseVC {

    @IBOutlet weak var scvContent: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var selectView:SelectCoachSepecialView?
    
    weak var delegate:SelectCoachSepecialDelegate?
    
    lazy var btnCommit: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 56, height: 24)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.setTitle("保存", for: .normal)
        btn.backgroundColor = YellowMainColor
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(BackgroundColor, for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        btn.enableInterval = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "教练专长"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btnCommit)
        selectView = SelectCoachSepecialView.instanceFromNib()
        stackView.addArrangedSubview(selectView!)
        
        
    }
    
    @objc func btnClick() {

        self.delegate?.selectTags((selectView?.getDicData()!)!)
        self.navigationController?.popViewController(animated: true)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
