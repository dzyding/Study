//
//  LocationSortFilterView.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LocationSortFilterViewDelegate: class {
    func sortView(_ sortView: LocationSortFilterView,
                  didClickBtn btn: UIButton)
    func sortView(_ sortView: LocationSortFilterView,
                  willRemoveFromSuperView view: UIView?)
}

class LocationSortFilterView: UIView, InitFromNibEnable, ShowInViewProtocol {
    
    weak var delegate: LocationSortFilterViewDelegate?
    
    @IBOutlet weak var stackView: UIStackView!
    
    var originFrame = CGRect(x: 0, y: 0,
                             width: ScreenWidth, height: 160)
    
    var isShow = false {
        willSet {
            if !newValue {
                delegate?.sortView(self,
                                   willRemoveFromSuperView: nil)
            }
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        layer.masksToBounds = true
        scale()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        original()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        dismiss()
        stackView.arrangedSubviews.forEach { (view) in
            if let btn = view as? UIButton {
                btn.isSelected = btn.tag == sender.tag
            }
        }
        delegate?.sortView(self, didClickBtn: sender)
    }
}
