//
//  HouseDetailBottomView.swift
//  YJF
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HouseDetailBottomViewDelegate {
    /// 收藏
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectFaviBtn btn: UIButton)
    /// 左边的按钮
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectLeftBtn btn: UIButton)
    /// 右边的按钮
    func bottomView(_ bottomView: HouseDetailBottomView, didSelectRightBtn btn: UIButton)
}

enum HouseDetailBottomType {
    case house  //房源详情
    case bid    //竞价
}

class HouseDetailBottomView: UIView, CheckLockDestroyProtocol {
    
    @IBOutlet weak var dealLB: UILabel!
    
    weak var delegate: HouseDetailBottomViewDelegate?

    @IBOutlet private weak var leftBtn: UIButton!
    
    @IBOutlet private weak var rightBtn: UIButton!
    
    @IBOutlet private weak var faviBtn: UIButton!
    
    @IBOutlet weak var faviView: UIView!
    
    @IBOutlet weak var leftLC: NSLayoutConstraint!
    
    @IBOutlet weak var dealView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        leftBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
        leftBtn.layer.borderWidth = 1
    }
    
    func hidenBtn() {
        leftBtn.isHidden = true
        rightBtn.isHidden = true
    }
    
    func setType(_ type: HouseDetailBottomType,
                 identity: Identity,
                 data: [String : Any],
                 isDeal: Bool)
    {
        let house = data.dicValue("house") ?? [:]
        /**
            已成交
         
            并且是买方，就显示已成交
            如果是卖方，并且门锁不可用就显示已成交
         */
        if isDeal {
            if identity == .buyer ||
                (identity == .seller && !isLockCanUse(house))
            {
                dealView.isHidden = false
                dealLB.text = "已成交"
                return
            }
        }
        let status = house.intValue("status") ?? 10
        if identity == .buyer && status > 40 {
            dealView.isHidden = false
            dealLB.text = "未生效"
            return
        }
        dealView.isHidden = true
        faviBtn.isSelected = data.intValue("isCollect") == 1
        switch type {
        case .house:
            leftBtn.setTitle("报告门锁故障", for: .normal)
            rightBtn.setTitle("我要看房", for: .normal)
            
            if identity == .seller {
                faviView.isHidden = true
                leftLC.constant = 18
            }
        case .bid:
            leftBtn.setTitle("撤销报价", for: .normal)
            rightBtn.setTitle("修改报价", for: .normal)
        }
    }
    
    func updateFavBtn(_ isSelected: Bool) {
        faviBtn.isSelected = isSelected
    }
    
    @IBAction func leftAction(_ sender: UIButton) {
        delegate?.bottomView(self, didSelectLeftBtn: sender)
    }
    
    @IBAction func rightAction(_ sender: UIButton) {
        delegate?.bottomView(self, didSelectRightBtn: sender)
    }
    
    @IBAction func faviAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.bottomView(self, didSelectFaviBtn: sender)
    }
}
