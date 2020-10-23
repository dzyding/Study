//
//  TPTextField.swift
//  PPBody
//
//  Created by edz on 2020/1/9.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import Foundation

protocol TPTextFieldDelegate: class {
    func tf(_ tf: TPTextField,
            didSelectAction action: TPKeyboardActionType)
}

class TPTextField: UITextField {
    
    weak var tpDelegate: TPTextFieldDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
    override func canPerformAction(_ action: Selector,
                                   withSender sender: Any?) -> Bool
    {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
    
    func insert(_ insetMsg: String)
    {
        if var text = text {
            if let sr = selectedRange(),
                let range = dzy_toRange(sr, str: text)
            {
                text.replaceSubrange(range, with: insetMsg)
                self.text = text
                setSelectedRange(NSRange(
                    location: sr.location + insetMsg.count,
                    length: 0))
            }else {
                self.text = text + insetMsg
                setSelectedRange(NSRange(
                    location: text.count + insetMsg.count,
                    length: 0))
            }
        }else {
            self.text = insetMsg
            setSelectedRange(
                NSRange(location: insetMsg.count, length: 0))
        }
    }
    
    func selectedRange() -> NSRange? {
        guard let sRange = selectedTextRange else {
            return nil
        }
        return NSRange(
            location: offset(from: beginningOfDocument,
                             to: sRange.start),
            length: offset(from: sRange.start, to: sRange.end))
    }
    
    func setSelectedRange(_ range: NSRange) {
        guard let from = position(from: beginningOfDocument, offset: range.location),
        let to = position(from: beginningOfDocument, offset: range.location + range.length)
        else {return}
        selectedTextRange = textRange(from: from, to: to)
    }
    
    //    MARK: - 懒加载
    private lazy var kb: TPKeyboardView = {
        let view = TPKeyboardView.initFromNib()
        view.delegate = self
        return view
    }()
}

extension TPTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        inputView = kb
        return true
    }
}

extension TPTextField: TPKeyboardViewDelegate {
        
    func kb(_ kb: TPKeyboardView, didSelectNum num: Int) {
        text.flatMap({
            if $0 == "0" {
                text = "\(num)"
            }else {
                insert("\(num)")
            }
        })
    }
    
    func kb(_ kb: TPKeyboardView, didSelectAction action: TPKeyboardActionType) {
        switch action {
        case .add:
            if let text = text,
                let num = Int(text)
            {
                self.text = "\(num + 1)"
            }else {
                self.text = "1"
            }
        case .reduce:
            if let text = text,
                let num = Int(text),
                num > 0
            {
                self.text = "\(num - 1)"
            }else {
                self.text = "0"
            }
        case .dot:
            if text?.contains(".") == true {
                return
            }
            insert(".")
        case .delete:
            if var text = text,
                text.count > 1,
                let sr = selectedRange()
            {
                if sr.length > 0 {
                    guard let range = dzy_toRange(sr, str: text) else {return}
                    text.removeSubrange(range)
                    if text.count == 0 {
                        self.text = "0"
                        setSelectedRange(NSRange(location: 1, length: 0))
                    }else {
                        self.text = text
                        setSelectedRange(NSRange(location: sr.location, length: 0))
                    }
                }else {
                    if sr.location == 0 {return}
                    let index = text.index(text.startIndex, offsetBy: sr.location - 1)
                    text.remove(at: index)
                    if text.hasPrefix(".") {
                        text.insert("0", at: text.startIndex)
                        self.text = text
                        setSelectedRange(NSRange(location: sr.location, length: 0))
                    }else {
                        self.text = text
                        setSelectedRange(NSRange(location: sr.location - 1, length: 0))
                    }
                    
                }
            }else {
                text = "0"
            }
        case .next,
             .addGroup:
            tpDelegate?.tf(self, didSelectAction: action)
        }
    }
}
