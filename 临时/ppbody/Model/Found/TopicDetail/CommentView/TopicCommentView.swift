//
//  TopicCommentView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol CommentSuccessActionDelegate: NSObjectProtocol {
    func commentSuccessIndexPath(_ indexPath:IndexPath)
}

class TopicCommentView: UIView {
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var bgView: UIView!

    var tid = ""
    
    var indexPath:IndexPath!
    
    var isPublishingComment = false

    weak var delegate: CommentSuccessActionDelegate?
    
    @IBAction func directAction(_ sender: UIButton) {
    }
    
    class func instanceFromNib() -> TopicCommentView {
        return UINib(nibName: "TopicCommentView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! TopicCommentView
    }
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hiden)))
        self.commentTF.delegate = self
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        self.commentTF.becomeFirstResponder()
    }
    
    @objc func hiden()
    {
        self.commentTF.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight)
        }) { (finish) in
            if finish{
                self.removeFromSuperview()
            }
        }
    }
    
    deinit {
        dzy_log("销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        let userInfo = note.userInfo!
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let deltaY = keyBoardBounds.size.height
//        self.commentTF.text = ""
        let animations:(() -> Void) = {
            self.bottomMargin.constant = CGFloat(deltaY) - (IS_IPHONEX ? CGFloat(SafeBottom) : 0 )
            self.layoutIfNeeded()
        }
        
        let delay = 0.0

        
        UIView.animate(withDuration: duration, delay: delay, options: .curveLinear, animations: animations, completion: nil)
    }
    
    @objc func keyboardWillHidden(note: NSNotification) {
        let userInfo  = note.userInfo!
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            //键盘的偏移量
            self.bottomMargin.constant = 0
            self.layoutIfNeeded()
        }
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations) { (finish) in
                if finish
                {
                }
            }
        }else{
            animations()
        }
    }
    
    func setComment()
    {
        if (self.commentTF.text?.isEmpty)!
        {
            return
        }
        let request = BaseRequest()
        request.dic = ["content":self.commentTF.text!, "tid":tid]
        request.url = BaseURL.TopicCommentPublic
        request.isUser = true
        request.start { (data, error) in
            
            self.isPublishingComment = false
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            self.commentTF.text = ""
            ToolClass.showToast("评论成功", .Success)
            
            self.delegate?.commentSuccessIndexPath(self.indexPath)
        }
    }
}

extension TopicCommentView: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !isPublishingComment
        {
            isPublishingComment = true
            setComment()
        }
        
        hiden()
        return true
    }
}
