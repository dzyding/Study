//
//  BuyOrderProgressVC.swift
//  YJF
//
//  Created by edz on 2019/5/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class OrderProgressVC: BaseVC {
    
    let type: Identity
    
    @IBOutlet private weak var contentStackView: UIStackView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var startLB: UILabel!
    
    @IBOutlet weak var dayLB: UILabel!
    
    @IBOutlet weak var endLB: UILabel!
    
    init(_ type: Identity) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //    MARK: - 界面初始化
    func initUI(_ data: [String: Any]?, identity: Identity) {
        let key = identity == .buyer ? "myAnaphasisList" : "otherAnaphasisList"
        let list = data?.arrValue(key) ?? []
        list.enumerated().forEach { (index, data) in
            let handler: ([String : Any]) -> () = { [weak self] data in
                self?.updateUI(data)
            }
            addProgressView(data, identity: identity, handler: handler)
            if index == 0 {
                self.updateUI(data)
            }
        }
    }
    
    //    MARK: - 设置下面的当前选中任务
    private func updateUI(_ data: [String : Any]) {
        guard let number = data.stringValue("number"),
            let dic = DataManager.evaluateConfig()?.dicValue(number),
            let title = dic.stringValue("name")
        else {return}
        
        nameLB.text = title
        startLB.text = data.stringValue("startTime")
        endLB.text = data.stringValue("planEndTime")
        let day = data.intValue("postponeDay") ?? 1
        dayLB.text = "\(day)个工作日"
    }
    
    //    MARK: - 通用的添加视图方法
    private func addProgressView(_ data: [String : Any],
                         identity: Identity,
                         handler: ([String : Any])->())
    {
        let status = data.intValue("status") ?? 10
        switch status {
        case 50:
            addFailView(data, identity: identity)
        case 40:
            addFinishView(data, identity: identity)
        case 30:
            addCurrentView(data, identity: identity)
            handler(data)
        default: // 10未领取,20待执行,60任务关闭
            addWaitView(data, identity: identity)
        }
    }
    
    // 还未开始的
    private func addWaitView(_ data: [String : Any], identity: Identity) {
        baseFunc(data,
                 identity: identity,
                 name: "order_progress_wait",
                 color: dzy_HexColor(0xA3A3A3)
        )
    }
    
    // 失败的
    private func addFailView(
        _ data: [String : Any], identity: Identity)
    {
        baseFunc(data,
                 identity: identity,
                 name: "order_progress_fail",
                 color: dzy_HexColor(0xA3A3A3)
        )
    }
    
    // 已经完成的
    private func addFinishView(_ data: [String : Any], identity: Identity) {
        baseFunc(data,
                 identity: identity,
                 name: "order_progress_finish",
                 color: dzy_HexColor(0x646464)
        )
    }
    
    // 正在执行的
    private func addCurrentView(
        _ data: [String : Any], identity: Identity)
    {
        baseFunc(data,
                 identity: identity,
                 name: "order_progress_current",
                 color: dzy_HexColor(0x262626)
        )
    }
    
    private func baseFunc(_ data: [String : Any],
                          identity: Identity,
                          name: String,
                          color: UIColor)
    {
        guard let number = data.stringValue("number"),
            let dic = DataManager.evaluateConfig()?.dicValue(number),
            let title = dic.stringValue("name")
        else {return}
        let view = OrderProgressView.initFromNib(OrderProgressView.self)
        view.isUserInteractionEnabled = true
        view.handler = { [weak self] in
            self?.updateUI(data)
        }
        if let imageView = view.viewWithTag(1) as? UIImageView {
            imageView.image = UIImage(named: name)
        }
        
        if let titleLB = view.viewWithTag(2) as? UILabel {
            titleLB.textColor = color
            titleLB.font = dzy_Font(13)
            titleLB.text = title
        }
        contentStackView.addArrangedSubview(view)
    }
}
