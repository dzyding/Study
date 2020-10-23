//
//  HomeDetailEditView.swift
//  YJF
//
//  Created by edz on 2019/4/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

@objc protocol HouseDetailEditViewDelegate {
    func editView(_ editView: HouseDetailEditView, didClickSureBtn btn: UIButton)
}

class HouseDetailEditView: UIView {
    
    weak var delegate: HouseDetailEditViewDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var editView: UIView!
    
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var textViewPlaceHolderLB: UILabel!
    
    @IBOutlet weak var showView: UIView!
    
    @IBOutlet weak var showLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textViewPlaceHolderLB.isHidden = textView.text.count > 0
        textView.delegate = self
    }
    
    func updateUI(_ remark: String, isInternal: Bool = false) {
        if remark.count == 0 && !isInternal {
            showView.isHidden = true
            editView.isHidden = false
        }else {
            var attStr = DzyAttributeString()
            attStr.str = remark
            attStr.font = dzy_Font(13)
            attStr.color = RGB(r: 163.0, g: 163.0, b: 163.0)
            attStr.lineSpace = defaultLineSpace
            showLB.attributedText = attStr.create()
            showLB.sizeToFit()
            var size = showLB.bounds.size
            size.height += 16
            scrollView.contentSize = size
        }
    }
    
    @IBAction private func sureAction(_ sender: UIButton) {
        guard textView.text.count > 0 else {
            ZKProgressHUD.showMessage("请输入备忘")
            return
        }
        showView.isHidden = false
        editView.isHidden = true
        textView.resignFirstResponder()
        
        updateUI(textView.text ?? "", isInternal: true)
        delegate?.editView(self, didClickSureBtn: sender)
    }
    
    @IBAction private func editAction(_ sender: UIButton) {
        let text = showLB.text ?? ""
        textView.text = text
        textViewPlaceHolderLB.isHidden = text.count > 0
        showView.isHidden = true
        editView.isHidden = false
    }
}

extension HouseDetailEditView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        textViewPlaceHolderLB.isHidden = text.count > 0
    }
}
