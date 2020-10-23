//
//  StatisticsMotionEditView.swift
//  PPBody
//
//  Created by edz on 2019/10/14.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol StatisticsMotionEditViewDelegate: class {
    func editView(_ editView: StatisticsMotionEditView,
                  didClickSaveBtn btn: UIButton,
                  datas: [[String : Any]])
}

class StatisticsMotionEditView: UIView, InitFromNibEnable {
    
    weak var delegate: StatisticsMotionEditViewDelegate?
    
    private let NumKey = "freNum"
    
    private let WeightKey = "weight"
    
    private let DeleteKey = "delete"
    /// 原始数据
    private var originDatas: [[String : Any]] = []
    /// 额外数据
    private var extraDatas: [[String : Any]] = []
    /// 原始数据中尚未删除的
    private var originCount: Int {
        return originDatas.filter({$0.intValue(DeleteKey) != 1}).count
    }

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    func initUI(_ datas: [[String : Any]], title: String) {
        titleLB.text = title
        while stackView.arrangedSubviews.count > 0 {
            stackView.arrangedSubviews.first?.removeFromSuperview()
        }
        originDatas = datas
        extraDatas = []
        datas.enumerated().forEach { (index, data) in
            addCell(data, index: index, isOrigin: true)
        }
    }
    
    private func addCell(_ data: [String : Any],
                         index: Int,
                         isOrigin: Bool
    ) {
        let cell = StatisticsMotionEditCell.initFromNib()
        if isOrigin {
            cell.originInitUI(data, index: index)
        }else {
            cell.extraInitUI(data, index: index, originCount: originCount)
        }
        cell.delegate = self
        stackView.addArrangedSubview(cell)
    }
    
    @IBAction private func closeAction(_ sender: UIButton) {
        (superview as? DzyPopView)?.hide()
    }
    
    @IBAction private func saveAction(_ sender: UIButton) {
        endEditing(true)
        let extraCount = extraDatas
            .filter({$0.doubleValue(NumKey) == 0}).count
        if extraCount > 0 {
            ToolClass.showToast("次数不能为0", .Failure)
            return
        }
        delegate?.editView(self,
                           didClickSaveBtn: sender,
                           datas: originDatas + extraDatas)
    }
    
    @IBAction private func addAction(_ sender: UIButton) {
        let data = [NumKey : 0.0, WeightKey : 0.0]
        addCell(data, index: extraDatas.count, isOrigin: false)
        extraDatas.append(data)
        let temp = scrollView.dzy_cSizeH - scrollView.dzy_h
        if temp > -45 {
            let point = CGPoint(x: 0, y: temp + 45.0)
            scrollView.setContentOffset(point, animated: true)
        }
    }
}

extension StatisticsMotionEditView: StatisticsMotionEditCellDelegate {
    func editCell(_ cell: StatisticsMotionEditCell,
                  editNumEnd tf: UITextField,
                  index: Int)
    {
        tf.text
            .map({$0.count > 0 ? $0 : "0"})
            .flatMap({Double($0)})
            .flatMap({
                if cell.tag == 99 {
                    originDatas[index][NumKey] = $0
                }else {
                    extraDatas[index][NumKey] = $0
                }
            })
    }
    
    func editCell(_ cell: StatisticsMotionEditCell,
                  editWeightEnd tf: UITextField,
                  index: Int)
    {
        tf.text
        .map({$0.count > 0 ? $0 : "0"})
        .flatMap({Double($0)})
        .flatMap({
            if cell.tag == 99 {
                originDatas[index][WeightKey] = $0
            }else {
                extraDatas[index][WeightKey] = $0
            }
        })
    }
    
    func editCell(_ cell: StatisticsMotionEditCell,
                  didClickDeleteBtn btn: UIButton,
                  index: Int)
    {
        cell.removeFromSuperview()
        var oCount = originCount
        if cell.tag == 99 {
            originDatas[index][DeleteKey] = 1
            oCount -= 1
            if oCount > 0 {
                (0..<oCount).forEach { (index) in
                    if let view = stackView.arrangedSubviews[index] as?
                        StatisticsMotionEditCell,
                        view.index >= index
                    {
                        view.updateUI(index)
                    }
                }
            }
        }else {
            extraDatas.remove(at: index)
        }
        (oCount..<stackView.arrangedSubviews.count).forEach { (i) in
            let view = stackView.arrangedSubviews[i]
            (view as? StatisticsMotionEditCell)?.updateUIAndIndex(i)
        }
    }
}
