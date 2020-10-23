//
//  WatchHouseSectionHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/9.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol WatchHouseSectionHeaderViewDelegate {
    func header(_ header: WatchHouseSectionHeaderView, openAction open: Bool)
}

class WatchHouseSectionHeaderView: UIView {
    
    weak var delegate: WatchHouseSectionHeaderViewDelegate?

    @IBOutlet private weak var titleLB: UILabel!
    
    @IBOutlet weak var openBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLB.text = IDENTITY == .buyer ? "房屋状况：" : "报告房屋损毁："
    }
    
    func updateUI(_ isOpen: Bool) {
        openBtn.isSelected = isOpen
    }
    
    @IBAction private func openAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.header(self, openAction: sender.isSelected)
    }
}
