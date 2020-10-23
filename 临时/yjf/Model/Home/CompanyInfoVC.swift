//
//  CompanyInfoVC.swift
//  YJF
//
//  Created by edz on 2019/7/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CompanyInfoVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "公司介绍"
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
