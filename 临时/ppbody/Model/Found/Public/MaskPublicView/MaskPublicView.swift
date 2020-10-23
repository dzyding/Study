//
//  MaskPublicView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import HBDNavigationBar

class MaskPublicView: UIView {
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topIV: UIImageView!
    @IBOutlet weak var topTitleLB: UILabel!
    @IBOutlet weak var topDetailLB: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomIV: UIImageView!
    @IBOutlet weak var bottomTitleLB: UILabel!
    @IBOutlet weak var bottomDetailLB: UILabel!
    
    var navigationVC: UINavigationController?
    
    class func instanceFromNib() -> MaskPublicView {
        let view = UINib(nibName: "MaskPublicView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0]
            as! MaskPublicView
        return view
    }
    
    override func awakeFromNib() {
        topView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(topAction))
        )
        bottomView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(bottomAction))
        )
    }
    
    func initUI() {
        topTitleLB.text = "图片"
        topDetailLB.text = "进入相册或拍摄"
        topIV.image = UIImage(named: "mask_select_pic")
        
        bottomTitleLB.text = "运动时刻"
        bottomIV.image = UIImage(named: "mask_short_video")
        if DataManager.isCoach(){
            bottomDetailLB.text = "短视频1分钟日常"
        }else{
            bottomDetailLB.text = "短视频15秒日常"
        }
    }
    
    @objc private func topAction() {
        let imgVC = ImagePublicVC()
        navigationVC?.pushViewController(imgVC, animated: true)
        removeFromSuperview()
    }
    
    @objc private func bottomAction() {
        let videoVC = VideoRecordVC()
        videoVC.hbd_barHidden = true
        let vc = HBDNavigationController(rootViewController: videoVC)
        vc.modalPresentationStyle = .fullScreen
        navigationVC?.present(vc, animated: true, completion: nil)
        removeFromSuperview()
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveLinear, animations: {
            self.centerY.constant = -30
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
}
