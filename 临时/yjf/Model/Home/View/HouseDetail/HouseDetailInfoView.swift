//
//  HouseDetailInfoView.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class HouseDetailInfoView: UIView {

    @IBOutlet weak var leftStackView: UIStackView!

    @IBOutlet weak var rightStackView: UIStackView!
    
    @IBOutlet weak var bottomView: UIView!
    
    private var url: String = ""
    
    @IBAction func btnAction(_ sender: UIButton) {
        let vc = HouseCodeVC(url)
        ToolClass.controller2(view: self)?.dzy_push(vc)
    }
    
    //swiftlint:disable:next function_body_length
    func updateUI(_ data: [String : Any], isDeal: Bool, identity: Identity) {
        [leftStackView, rightStackView].forEach { (sv) in
            if let sv = sv {
                while sv.arrangedSubviews.count > 0 {
                    sv.arrangedSubviews.first?.removeFromSuperview()
                }
            }
        }
        let house = data.dicValue("house") ?? [:]
        var date = house.stringValue("year")?.components(separatedBy: " ").first
        if let temp = date,
            temp.count > 3,
            ScreenWidth <= 375
        {
            let index = temp.index(temp.startIndex, offsetBy: 2)
            date = String(temp[index...])
        }
        // 已成交，并且是买方
        let roomNum = (isDeal && identity == .buyer) ?
            "*** ***" : (house.stringValue("roomNum") ?? "")
        [
            ("门牌号：", roomNum),
            ("区域：", house.stringValue("region") ?? ""),
            ("户型：", house.stringValue("layout") ?? ""),
            ("装修：", house.stringValue("renovation") ?? ""),
            ("建成日期：", date ?? ""),
            ("设计用途：", house.stringValue("purpose") ?? ""),
            ("产权：", house.stringValue("property") ?? "")
            ].enumerated().forEach { (index, value) in
                let infoView = InfoMsgView(frame: .zero, ifBold: index == 0)
                infoView.nameLB?.text = value.0
                infoView.msgLB?.text = value.1
                leftStackView.addArrangedSubview(infoView)
        }
        
        let floorStr = String(
            format: "%ld层（共%ld层）",
            house.intValue("floor") ?? 0,
            house.intValue("totalFloor") ?? 0
        )
        [
            ("编号：", house.stringValue("code") ?? ""),
            ("小区：", house.stringValue("community") ?? ""),
            ("面积：", "\(house.doubleValue("area"), optStyle: .price)㎡"),
            ("所在楼层：", floorStr),
            ("电梯：", "\(house.intValue("lift") ?? 0)部"),
            ("朝向：", house.stringValue("orientation") ?? ""),
            (" ", " ")
            ].enumerated().forEach { (index, value) in
                let infoView = InfoMsgView(frame: .zero, ifBold: index == 0)
                infoView.nameLB?.text = value.0
                infoView.msgLB?.text = value.1
                rightStackView.addArrangedSubview(infoView)
        }
        let infoView = InfoMsgView(frame: bottomView.bounds, ifBold: false)
        infoView.nameLB?.text = "房产编号："
        infoView.msgLB?.text = house.stringValue("verifyCode")
        url = house.stringValue("verifyWebsite") ?? ""
        bottomView.insertSubview(infoView, at: 0)
    }
}

private class InfoMsgView: UIView {
    
    weak var nameLB: UILabel?
    
    weak var msgLB: UILabel?
    
    init(frame: CGRect, ifBold: Bool) {
        super.init(frame: frame)
        setUI(ifBold)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI(_ ifBold: Bool) {
        let nameLB = UILabel()
        nameLB.textColor = dzy_HexColor(0xA3A3A3)
        nameLB.font = ifBold ? dzy_FontBlod(13) : dzy_Font(13)
        nameLB.textAlignment = .left
        addSubview(nameLB)
        self.nameLB = nameLB
        
        let msgLB = UILabel()
        msgLB.textColor = dzy_HexColor(0x262626)
        msgLB.font = ifBold ? dzy_FontBlod(13) : dzy_Font(13)
        msgLB.textAlignment = .left
        msgLB.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(msgLB)
        self.msgLB = msgLB
        
        nameLB.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalTo(self)
        }
        
        msgLB.snp.makeConstraints { (make) in
            make.left.equalTo(nameLB.snp.right)
            make.centerY.equalTo(self)
            make.right.lessThanOrEqualTo(0)
        }
    }
}
