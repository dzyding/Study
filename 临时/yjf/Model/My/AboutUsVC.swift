//
//  AboutUsVC.swift
//  YJF
//
//  Created by edz on 2020/4/27.
//  Copyright © 2020 灰s. All rights reserved.
//

import UIKit

class AboutUsVC: BaseVC {

    @IBOutlet weak var versionLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "关于我们"
        (Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String)
        .flatMap({
            versionLB.text = "易间房APP V\($0)"
        })
    }

    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let code = "027-87750030"
            guard let url = URL(string: "tel:" + code) else {return}
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet)
            if #available(iOS 13.0, *) {
                alert.overrideUserInterfaceStyle = .light
            }
            let cancelAction = UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil)
            alert.addAction(cancelAction)
            let codeAction = UIAlertAction(
                title: code,
                style:
                .default)
            { (_) in
                UIApplication.shared.open(url)
            }
            alert.addAction(codeAction)
            present(alert, animated: true, completion: nil)
        case 2:
            let vc = UserProtocolVC()
            dzy_push(vc)
        case 3:
            let vc = PrivacyProtocolVC()
            dzy_push(vc)
        case 4:
            let vc = CheckSystemVC()
            dzy_push(vc)
        default:
            break
        }
    }
}
