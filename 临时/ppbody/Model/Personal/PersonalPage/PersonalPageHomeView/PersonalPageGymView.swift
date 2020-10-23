//
//  PersonalPageGymView.swift
//  PPBody
//
//  Created by edz on 2019/11/8.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class PersonalPageGymView: UIView {

    @IBOutlet weak var logoIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var addressLB: UILabel!
    
    @IBOutlet weak var distanceLB: UILabel!
    
    private var cid: String?
    
    class func instanceFromNib() -> PersonalPageGymView {
        return UINib(nibName: "PersonalPageHomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[6] as! PersonalPageGymView
    }
    
    @IBAction func gymAction(_ sender: UIButton) {
        cid.flatMap({
            let vc = LocationGymVC($0)
            ToolClass.controller2(view: self)?.dzy_push(vc)
        })
        
    }
    
    func updateUI(_ gym: [String : Any]) {
        cid = gym.stringValue("cid")
        let url = gym.stringValue("logo") ?? gym.stringValue("cover")
        logoIV.setCoverImageUrl(url ?? "")
        nameLB.text = gym.stringValue("name")
        addressLB.text = gym.stringValue("address")
        
        let manager = LocationManager.locationManager
        if let lon1 = gym.doubleValue("longitude"),
            let lat1 = gym.doubleValue("latitude"),
            let lon2 = Double(manager.longitude),
            let lat2 = Double(manager.latitude)
        {
            
            let x = LocationManager.distanceBetweenTwoPoint(lon1,
                                                            lon1: lat1,
                                                            lat2: lon2,
                                                            lon2: lat2)
            distanceLB.text = (x / 1000.0).decimalStr + "km"
        }else {
            distanceLB.text = nil
        }
    }
}
