//
//  HouseCodeVC.swift
//  YJF
//
//  Created by edz on 2020/1/18.
//  Copyright © 2020 灰s. All rights reserved.
//

import UIKit

class HouseCodeVC: BaseVC {

    @IBOutlet weak var qrIV: UIImageView!
    
    private let url: String
    
    init(_ url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "房源查询网址"
        qrIV.image = dzy_QrCode(url, size: 714.0)
    }

    @IBAction func copyActon(_ sender: Any) {
        UIPasteboard.general.string = url
        ToolClass.showToast("复制成功", .Success)
    }
}
