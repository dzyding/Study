//
//  OrderProgressBaseVC.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class OrderProgressBaseVC: ScrollBtnVC {
    
    override var normalFont: UIFont {
        return dzy_FontBlod(13)
    }
    
    override var selectedFont: UIFont {
        return dzy_FontBlod(15)
    }
    
    override var normalColor: UIColor {
        return dzy_HexColor(0x646464)
    }
    
    override var selectedColor: UIColor {
        return dzy_HexColor(0x262626)
    }
    
    override var btnsViewHeight: CGFloat {
        return 44
    }
    
    override var lineToBottom: CGFloat {
        return 8
    }
    
    override var isPaddingLine: Bool {
        return true
    }
    
    override var paddingLineColor: UIColor {
        return dzy_HexColor(0xe5e5e5)
    }
    
    override var titles: [String] {
        return IDENTITY == .buyer ?
            ["我的交易进展", "卖方交易进展"] :
            ["我的交易进展", "买方交易进展"]
    }
    
    let houseId: Int
    
    let dealNo: String
    
    init(_ houseId: Int, dealNo: String) {
        self.houseId = houseId
        self.dealNo = dealNo
        super.init(.topTop)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "交易进展"
        updateVCs()
        progressApi()
    }
    
    override func getVCs() -> [UIViewController] {
        return IDENTITY == .buyer ?
            [OrderProgressVC(.buyer), OrderProgressVC(.seller)] :
            [OrderProgressVC(.seller), OrderProgressVC(.buyer)]
    }
    
    private func updateSubVC(_ data: [String : Any]?) {
        children.forEach { (temp) in
            if let vc = temp as? OrderProgressVC {
                if vc.type == .buyer {
                    vc.initUI(data, identity: .buyer)
                }else {
                    vc.initUI(data, identity: .seller)
                }
            }
        }
    }

    private func progressApi() {
        let request = BaseRequest()
        request.url = BaseURL.orderProgress
        request.dic = [
            "houseId" : houseId,
            "dealNo"  : dealNo,
            "type" : IDENTITY == .seller ? 10 : 20
        ]
        request.isUser = true
        request.dzy_start { (data, _) in
            self.updateSubVC(data)
        }
    }
}
