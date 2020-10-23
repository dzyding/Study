//
//  CoachCertifyStatusVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachCertifyStatusVC: BaseVC {
    
    @IBOutlet weak var btnResult: UIButton!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var btnOne: UIButton!
    
    var statusType: NSNumber = 10 //10待审核 20审核驳回 30审核成功

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "认证审核"
        
        if statusType == 10 {
            lblDesc.text = "请稍等，您的资料正在审核中～"
        }
        else if statusType == 20 {
            lblDesc.text = "很抱歉，您审核不通过～"
        }
        else if statusType == 30 {
            lblDesc.text = "恭喜您，通过了教练认证，重新打开APP可获得教练特权～"
        }
        //直接返回到主视图
        let arr = [self.navigationController?.viewControllers[0],self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-1]]
        self.navigationController?.setViewControllers(arr as! [UIViewController], animated: true)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
