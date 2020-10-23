//
//  CoachCertifyVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/30.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class CoachCertifyVC: BaseVC {

    @IBOutlet weak var btnCommit: UIButton!
    @IBOutlet weak var imgSex: UIImageView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnTwo: UIButton!
    @IBOutlet weak var btnOne: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "教练认证"

        let head = DataManager.getHead()
        self.imgIcon.setHeadImageUrl(head)
        
    }
    
    @IBAction func btnClick(_ sender: UIButton) {
        let vc = SetCoachInfoVC.init(nibName: "SetCoachInfoVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
