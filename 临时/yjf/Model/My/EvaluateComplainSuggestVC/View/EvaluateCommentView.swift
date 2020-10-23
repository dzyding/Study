//
//  EvaluateCommentView.swift
//  YJF
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class EvaluateCommentView: UIView {
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var placeHolderLB: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }
    
    /// 修改成投诉的样式
    func changeToComplainType() {
        titleLB.text = "投诉内容"
        placeHolderLB.text = "请输入您的投诉内容"
    }
    
    /// 修改成建议的样式
    func changeToSuggestType() {
        titleLB.text = "建议内容"
        placeHolderLB.text = "请输入您的建议内容"
    }
}

extension EvaluateCommentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLB.isHidden = textView.text.count > 0
    }
}
