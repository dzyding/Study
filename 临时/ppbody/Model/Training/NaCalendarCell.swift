//
//  NaCalendarCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

enum SelectionType : Int {
    case none
    case full
}

class NaCalendarCell: FSCalendarCell {

    weak var circleImageView: UIImageView!
    
    var selectionType: SelectionType = .none {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let circleImageView = UIImageView()
        self.contentView.insertSubview(circleImageView, at: 0)
        self.circleImageView = circleImageView
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        circleImageView.frame = CGRect(x: (contentView.bounds.width-contentView.bounds.height)/2, y: -4, width: contentView.bounds.height, height: contentView.bounds.height)
        if selectionType == .full {
            circleImageView.image = UIImage(named: "hp_full_selected")
        }else {
            circleImageView.image = nil
        }
    }
}
