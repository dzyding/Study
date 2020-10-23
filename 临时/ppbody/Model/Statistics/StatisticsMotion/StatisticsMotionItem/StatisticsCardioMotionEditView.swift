//
//  StatisticsCardioMotionEditView.swift
//  PPBody
//
//  Created by edz on 2019/10/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class StatisticsCardioMotionEditView: UIView, InitFromNibEnable {

    @IBOutlet private weak var titleLB: UILabel!
    
    @IBOutlet private weak var minTF: UITextField!
    // 操作的日期
    private var date: String = ""
    
    private var data: [String : Any] = [:]
    
    private var gId: Int = 0
    
    var handler: (([String : Any], String, Int)->())?
    
    func updateUI(_ data: [String : Any], title: String?) {
        self.data = data.arrValue("list")?.first ?? [:]
        self.gId = data.intValue("userMotionGroupId") ?? 0
        let stime = data.doubleValue("time") ?? 0
        minTF.addTarget(self,
                        action: #selector(minChangedAction(_:)),
                        for: .editingChanged)
        minTF.text = String(format: "%.1lf", stime / 60.0)
        titleLB.text = title
        date = data.stringValue("createTime")?
            .components(separatedBy: " ").first ?? ""
    }
    
    @objc private func minChangedAction(_ tf: UITextField) {
        tf.checkIsOnlyNumber()
    }
    
    @IBAction private func closeAction(_ sender: UIButton) {
        (superview as? DzyPopView)?.hide()
    }
    
    @IBAction private func saveAction(_ sender: UIButton) {
        guard let min = minTF.text,
            let value = Double(min),
            value > 0
        else {
            ToolClass.showToast("请输入正确的分钟数值", .Failure)
            return
        }
        data["time"] = value * 60.0
        handler?(data, date, gId)
    }
}
