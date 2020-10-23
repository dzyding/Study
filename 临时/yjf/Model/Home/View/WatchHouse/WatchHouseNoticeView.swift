//
//  WatchHouseNoticeHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/9.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol WatchHouseNoticeViewDelegate {
    func noticeView(_ noticeView: WatchHouseNoticeView, didSelectEndBtn btn: UIButton)
}

class WatchHouseNoticeView: UIView {
    
    weak var delegate: WatchHouseNoticeViewDelegate?

    @IBAction func endAction(_ sender: UIButton) {
        delegate?.noticeView(self, didSelectEndBtn: sender)
    }
    
}
