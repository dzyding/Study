//
//  SuggestVC.swift
//  YJF
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class SuggestVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentView.changeToSuggestType()
        view.addSubview(commentView)
        commentView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(10)
        }
    }
    
    @IBAction func suggestAction(_ sender: UIButton) {
        view.endEditing(true)
        guard let comment = commentView.textView.text, comment.count > 0 else {
            showMessage("请输入建议内容")
            return
        }
        suggestApi(comment)
    }
    
    private func suggestApi(_ str: String) {
        let request = BaseRequest()
        request.url = BaseURL.submitFeed
        request.dic = ["content" : str]
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                self.showMessage("提交成功")
                self.commentView.textView.text = nil
                self.commentView.placeHolderLB.isHidden = false
            }
        }
    }
    
    //    MARK: - 懒加载
    /// 评价
    private lazy var commentView: EvaluateCommentView = {
        let cview = EvaluateCommentView.initFromNib(EvaluateCommentView.self)
        return cview
    }()
}
