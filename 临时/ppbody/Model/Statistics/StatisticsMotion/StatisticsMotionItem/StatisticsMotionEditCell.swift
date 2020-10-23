//
//  StatisticsMotionEditCell.swift
//  PPBody
//
//  Created by edz on 2019/10/14.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol StatisticsMotionEditCellDelegate: class {
    func editCell(_ cell: StatisticsMotionEditCell,
                  editNumEnd tf: UITextField,
                  index: Int)
    
    func editCell(_ cell: StatisticsMotionEditCell,
                  editWeightEnd tf: UITextField,
                  index: Int)
    
    func editCell(_ cell: StatisticsMotionEditCell,
                  didClickDeleteBtn btn: UIButton,
                  index: Int)
}

class StatisticsMotionEditCell: UIView, InitFromNibEnable {
    
    weak var delegate: StatisticsMotionEditCellDelegate?
    
    @IBOutlet private weak var noLB: UILabel!
    
    @IBOutlet private weak var numTF: UITextField!
    
    @IBOutlet private weak var weightTF: UITextField!
    
    var index = 0
    
    func originInitUI(_ data: [String : Any], index: Int) {
        tag = 99
        noLB.text = "\(index + 1)"
        baseInitUI(data, index: index)
    }
    
    func extraInitUI(_ data: [String : Any], index: Int, originCount: Int) {
        noLB.text = "\(index + originCount + 1)"
        baseInitUI(data, index: index)
    }
    
    func updateUIAndIndex(_ index: Int) {
        self.index = index
        noLB.text = "\(index + 1)"
    }
    
    func updateUI(_ index: Int) {
        noLB.text = "\(index + 1)"
    }
    
//    MARK: - private
    private func baseInitUI(_ data: [String : Any], index: Int) {
        weightTF.addTarget(self,
                           action: #selector(weightChangedAction(_:)),
                           for: .editingChanged)
        numTF.addTarget(self,
                        action: #selector(numChangedAction(_:)),
                        for: .editingChanged)
        self.index = index
        numTF.delegate = self
        weightTF.delegate = self
        numTF.text = "\(data.doubleValue("freNum"), optStyle: .price)"
        weightTF.text = "\(data.doubleValue("weight"), optStyle: .price)"
    }
    
    @IBAction private func delAction(_ sender: UIButton) {
        delegate?.editCell(self, didClickDeleteBtn: sender, index: index)
    }
    
    @objc private func weightChangedAction(_ tf: UITextField) {
        tf.checkIsOnlyNumber()
    }
    
    @objc private func numChangedAction(_ tf: UITextField) {
        tf.checkIsOnlyNumber(false)
    }
}

extension StatisticsMotionEditCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == numTF {
            delegate?.editCell(self, editNumEnd: textField, index: index)
        }else if textField == weightTF {
            delegate?.editCell(self, editWeightEnd: textField, index: index)
        }
    }
}
