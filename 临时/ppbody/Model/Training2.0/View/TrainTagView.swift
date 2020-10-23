//
//  TrainTagView.swift
//  PPBody
//
//  Created by edz on 2019/12/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainTagView: UIView, InitFromNibEnable {

    @IBOutlet weak var mTitleLB: UILabel!
    @IBOutlet weak var mMoreLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mTitleLB.font = dzy_FontBBlod(16)
        mMoreLB.font = dzy_FontBlod(12)
        hotDataApi()
    }
    
    private func initUI(_ list: [[String : Any]]) {
        list.forEach { (data) in
            let sView = TrainTagSourceView.initFromNib()
            sView.initUI(data) { [weak self] in
                self?.detailAction(data)
            }
            stackView.addArrangedSubview(sView)
        }
    }
    
    @IBAction func moreAction(_ sender: Any) {
        let vc = TopicTagVC(.list)
        parentVC?.dzy_push(vc)
    }
    
    private func detailAction(_ data: [String : Any]) {
        let vc = TopicTagDetailVC()
        vc.tag = data.stringValue("name")
        parentVC?.dzy_push(vc)
    }
    
//    MARK: - api
    func hotDataApi() {
        let request = BaseRequest()
        request.page = [1, 30]
        request.url = BaseURL.HotTag
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let list = data?.arrValue("list") ?? []
            self.initUI(list)
        }
    }
}
