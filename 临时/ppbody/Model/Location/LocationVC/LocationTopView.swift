//
//  LocationTopView.swift
//  PPBody
//
//  Created by edz on 2019/10/22.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LocationTopViewDelegate: class {
    func topView(_ topView: LocationTopView, didClickMapBtn btn: UIButton)
    func topView(_ topView: LocationTopView, didClickNearbyBtn btn: UIButton)
    func topView(_ topView: LocationTopView, didClickSortBtn btn: UIButton)
    func topView(_ topView: LocationTopView, shouldBeginEditing tf: UITextField)
}

class LocationTopView: UIView, InitFromNibEnable {
    
    weak var delegate: LocationTopViewDelegate?

    @IBOutlet weak var cityBtn: UIButton!
    
    @IBOutlet weak var inputTF: UITextField!
    
    @IBOutlet weak var regionLB: UILabel!
    
    @IBOutlet weak var regionIV: UIImageView!
    
    @IBOutlet weak var sortLB: UILabel!
    
    @IBOutlet weak var sortIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTF.attributedPlaceholder = LocationVCHelper
            .shearchAttPlcaeHolder()
        inputTF.delegate = self
    }
    
    func updateCity(_ city: String) {
        cityBtn.setTitle(city, for: .normal)
    }
    
    func nearbyViewUpdate(_ isOpen: Bool) {
        let alaph: CGFloat = isOpen ? 1.0 : 0.6
        let textColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: alaph)
        regionLB.textColor = textColor
        let imageName = isOpen ? "loc_zk_top" : "loc_zk_bottom"
        regionIV.image = UIImage(named: imageName)
    }
    
    func regionLBUpdate(_ text: String) {
        regionLB.text = text
    }
    
    func sortViewUpdate(_ isOpen: Bool) {
        let alaph: CGFloat = isOpen ? 1.0 : 0.6
        let textColor = RGBA(r: 255.0, g: 255.0, b: 255.0, a: alaph)
        sortLB.textColor = textColor
        let imageName = isOpen ? "loc_zk_top" : "loc_zk_bottom"
        sortIV.image = UIImage(named: imageName)
    }
    
    func sortLBUpdate(_ text: String) {
        sortLB.text = text
    }
    
    @IBAction private func mapAction(_ sender: UIButton) {
        delegate?.topView(self, didClickMapBtn: sender)
    }
    
    @IBAction private func nearbyAction(_ sender: UIButton) {
        nearbyViewUpdate(true)
        delegate?.topView(self, didClickNearbyBtn: sender)
    }
    
    @IBAction private func sortAction(_ sender: UIButton) {
        sortViewUpdate(true)
        delegate?.topView(self, didClickSortBtn: sender)
    }
}

extension LocationTopView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.topView(self, shouldBeginEditing: textField)
        return false
    }
}
