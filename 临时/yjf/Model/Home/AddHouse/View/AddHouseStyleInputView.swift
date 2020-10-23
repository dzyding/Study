//
//  AddHouseStyleInputView.swift
//  YJF
//
//  Created by edz on 2019/5/30.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

enum HouseNumStyle {
    case custom     //自定义
    case `default`  //默认
}

class AddHouseStyleInputView: UIView {
    
    private let vTag = 7
    
    private let tfTag = 9
    
    private var titles: [String] = []
    
    private var placeHolders: [String?] = []
    /// 是否有最后一个输入框
    private var isHasLastTf = false
    
    private var scrollView = UIScrollView()
    
    var type: HouseNumStyle = .default
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    func getStr() -> String? {
        switch type {
        case .default:
            return defaultTypeStr()
        default:
            return customTypeStr()
        }
    }
    
    private func initUI() {
        scrollView.bounces = false
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets.zero)
        }
    }
    
    func set(_ str: String) {
        func getTF(_ tag: Int) -> UITextField? {
            if let inputView = scrollView.viewWithTag(tag),
                let tf = inputView.viewWithTag(tfTag) as? UITextField
            {
                return tf
            }else {
                return nil
            }
        }
        switch type {
        case .default:
            var temp = str
            for (index, title) in titles.enumerated() {
                if let tf = getTF(index) {
                    let arr = temp.components(separatedBy: title)
                    tf.text = arr.first
                    temp = arr.last ?? ""
                }
            }
            if placeHolders.count > titles.count,
                let tf = getTF(titles.count)
            {
                tf.text = temp
            }
        default:
            if let tf = getTF(vTag) {
                tf.text = str
            }
        }
    }
    
    private func defaultTypeStr() -> String? {
        var result = ""
        for (index, title) in titles.enumerated() {
            if let input = baseGetStr(index) {
                result += (input + title)
            }else {
//                ZKProgressHUD.showMessage("请输入\(title)")
                return nil
            }
        }
        // 最后有个单独的输入框
        if placeHolders.count > titles.count {
            if let input = baseGetStr(titles.count) {
                result += input
            }else {
//                ZKProgressHUD.showMessage("请完善门牌号")
                return nil
            }
        }
        return result
    }
    
    private func customTypeStr() -> String? {
        if let result = baseGetStr(vTag) {
            return result
        }else {
            ZKProgressHUD.showMessage("请输入门牌号")
            return nil
        }
    }
    
    // 获取输入结果的核心方法
    private func baseGetStr(_ index: Int) -> String? {
        if let inputView = scrollView.viewWithTag(index),
            let tf = inputView.viewWithTag(tfTag) as? UITextField,
            let input = tf.text,
            input.count > 0
        {
            return input
        }else {
            return nil
        }
    }

    func updateUI(_ style: String?, ph: String?) {
        while scrollView.subviews.count > 0 {
            scrollView.subviews.first?.removeFromSuperview()
        }
        if var style = style { // 有固定类型
            // 删除多余的空格
            style = style.replacingOccurrences(of: " ", with: "")
            type = .default
            titles = []
            isHasLastTf = false
            while style.firstIndex(of: "(") != nil {
                guard let sindex = style.firstIndex(of: "("),
                    let eindex = style.firstIndex(of: ")")
                else {break}
                // 截取显示用的 title 和 placeHolder
                func getTitleAndPH() {
                    // 如果 "(" 不是第一个
                    if sindex != style.startIndex {
                        let title = String(style[..<sindex])
                        titles.append(title)
                    }
                    let after = style.index(after: sindex)
                    if after < eindex {
                        let ph = String(style[after..<eindex])
                        placeHolders.append(ph)
                    }else {
                        placeHolders.append(nil)
                    }
                }
                if eindex == style.index(before: style.endIndex) {
                    getTitleAndPH()
                    isHasLastTf = true
                    style = ""
                }else {
                    getTitleAndPH()
                    style = String(style[style.index(after: eindex)...])
                }
            }
            if style.count > 0 {
                titles.append(style)
            }
            setSubViews()
        }else {
            type = .custom
            let input = getInputView(ph ?? "请输入门牌号")
            input.frame = scrollView.bounds
            input.tag = vTag
            scrollView.addSubview(input)
            scrollView.contentSize = scrollView.bounds.size
        }
    }
    
    private func setSubViews() {
        var tempLB: UILabel?
        var width: CGFloat = 0
        func getTempLBFrame() -> CGRect {
            var x: CGFloat = 0
            if let tempLB = tempLB {
                x = tempLB.frame.maxX + 4
            }else {
                x = 0
            }
            return CGRect(x: x, y: 0, width: 40.0, height: 45.0)
        }
        titles.enumerated().forEach { (index, title) in
            let placeHolder = index < placeHolders.count ?
                placeHolders[index] : nil
            let input = getInputView(placeHolder, keyboardType: .numberPad)
            input.tag = index
            scrollView.addSubview(input)
            
            let label = UILabel()
            label.textColor = Font_Dark
            label.font = dzy_FontBlod(14)
            label.text = title
            label.tag = 99
            scrollView.addSubview(label)
        
            input.frame = getTempLBFrame()
            
            label.sizeToFit()
            var lframe = label.frame
            lframe.origin.x = input.frame.maxX + 4
            lframe.size.height = 45.0
            label.frame = lframe
            tempLB = label
        }
        width = tempLB?.frame.maxX ?? 0
        
        if isHasLastTf {
            let placeHolder = placeHolders.count > titles.count ?
                placeHolders[titles.count] : nil
            let input = getInputView(placeHolder)
            input.tag = titles.count
            scrollView.addSubview(input)
    
            input.frame = getTempLBFrame()
            width += 40.0
        }
        scrollView.contentSize = CGSize(width: width, height: 45.0)
    }
    
    private func getInputView(
        _ placeHolder: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) -> UIView {
        let view = UIView()
        
        let textField = UITextField()
        textField.textColor = dzy_HexColor(0xa3a3a3)
        textField.borderStyle = .none
        textField.placeholder = placeHolder
        textField.font = dzy_Font(14)
        textField.tag = tfTag
        textField.keyboardType = keyboardType
        view.addSubview(textField)
        
        let line = UIView()
        line.backgroundColor = dzy_HexColor(0xe5e5e5)
        view.addSubview(line)
        
        textField.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.centerY.equalTo(view)
            make.height.equalTo(35)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(1)
        }
        
        return view
    }
}
