//
//  LGymInfoView.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LGymInfoViewDelegate: class {
    func infoView(_ infoView: LGymInfoView, didSelectImg index: Int)
    func infoView(_ infoView: LGymInfoView, didClickMapBtn btn: UIButton)
    func infoView(_ infoView: LGymInfoView, didClickTel btn: UIButton)
}

class LGymInfoView: UIView, InitFromNibEnable {
    
    weak var delegate: LGymInfoViewDelegate?
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var areaLB: UILabel!
    
    @IBOutlet weak var addressLB: UILabel!
    
    @IBOutlet weak var phoneView: UIView!
    
    func clickAction(_ index: Int) {
        delegate?.infoView(self, didSelectImg: index)
    }
    
    @IBAction func mapAction(_ sender: UIButton) {
        delegate?.infoView(self, didClickMapBtn: sender)
    }
    
    @IBAction func phoneAction(_ sender: UIButton) {
        delegate?.infoView(self, didClickTel: sender)
    }
    
    func initUI(_ info: [String : Any]) {
        let isTel = info.stringValue("tel")?.isEmpty ?? true
        phoneView.isHidden = isTel
        var imgs = info["imgs"] as? [String] ?? []
        if imgs.count == 0,
            let cover = info.stringValue("cover")
        {
            imgs.append(cover)
        }
        adView.updateUI(imgs, isTimer: false)
        addSubview(adView)
        
        nameLB.text = info.stringValue("name")
        //营业时间：周一至周日 09:00-22:00
        timeLB.text = "营业时间：" + (info.stringValue("hours") ?? "")
        //面积290m² | 可容纳50人
        let area = info.doubleValue("area") ?? 0
        let persons = info.intValue("persons") ?? 0
        if area > 0,
            persons > 0
        {
            areaLB.text = String(format: "面积%.0lfm² | 可容纳%ld人", area, persons)
        }else if area > 0 {
            areaLB.text = String(format: "面积%.0lfm²", area)
        }else if persons > 0 {
            areaLB.text = String(format: "可容纳%ld人", persons)
        }else {
            areaLB.text = "暂无面积信息"
        }
        addressLB.text = info.stringValue("address")
    }

//    MARK: - 懒加载
    private lazy var adView: DzyAdView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 240.0)
        let view = DzyAdView(frame, pageType: .num)
        view.handler = { [weak self] index in
            self?.clickAction(index)
        }
        return view
    }()
}
