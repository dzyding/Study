//
//  TopicCommentView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/18.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol TopicCommentActionDelegate: NSObjectProtocol {
    func supportComment(_ cell: UITableViewCell, isSelect:Bool,  indexPath:IndexPath)
    
    func tapHeadForIndex(_ indexPath:IndexPath)
}

class TopicCommentListView: UIView {
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableviewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var searchBgView: UIView!
    @IBOutlet weak var commentTF: UITextField!
    
    var tid = ""
    var topicUid = ""
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    var dataArr = [[String:Any]]()
    
    var indexPath:IndexPath!
    
    weak var delegate: CommentSuccessActionDelegate?

    var replyId:Int? //回复ID
    
    var isPublishingComment:Bool = false
    
    //分页数据
    var page : Dictionary<String,Any>? //分页
    //当前页数
    var currentPage : Int? {
        return self.page?["currentPage"] as? Int
    }
    //总页数
    var totalPage : Int?{
        return self.page?["totalPage"] as? Int
    }
    //总数
    var totalNum : Int?{
        return self.page?["totalNum"] as? Int
    }
    
    class func instanceFromNib() -> TopicCommentListView {
        return UINib(nibName: "TopicCommentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopicCommentListView
    }
    
    override func awakeFromNib() {
        
        if IS_IPHONEX
        {
            self.tableviewBottomMargin.constant = self.tableviewBottomMargin.constant + CGFloat(SafeBottom)
        }
        
        self.bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hiden)))
        
        self.searchBgView.layer.borderColor = Text1Color.cgColor
        self.searchBgView.layer.borderWidth = 1
        self.searchBgView.layer.cornerRadius = 17
        self.commentTF.delegate = self
        self.commentTF.attributedPlaceholder = NSAttributedString(string: "说你想说的话...", attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
  
        tableview.dzy_registerCellNib(CommentGiftCell.self)
        tableview.dzy_registerCellNib(CommentViewCell.self)
        tableview.dzy_registerCellNib(CommentReplyViewCell.self)
        
        self.editView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelCommentAction)))
        
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getCommentList(loadmore ? (self!.currentPage)!+1 : 1)
        }
        
        tableview.srf_addRefresher(refresh)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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

        let animations:(() -> Void) = {
            self.bottomMargin.constant = CGFloat(deltaY) - (IS_IPHONEX ? CGFloat(SafeBottom) : 0 )
            self.bottomView.backgroundColor = UIColor.white
            self.commentTF.textColor = BackgroundColor
            self.editView.isHidden = false
            self.layoutIfNeeded()
        }
        let delay = 0.0
        UIView.animate(withDuration: duration, delay: delay, options: .curveLinear, animations: animations, completion: nil)
        
    }
    
    @objc func keyboardWillHidden(note: NSNotification) {
        let userInfo  = note.userInfo!
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
    
        let animations:(() -> Void) = {
            self.bottomMargin.constant = 0
            self.bottomView.backgroundColor = UIColor.clear
            self.commentTF.textColor = UIColor.white
            self.editView.isHidden = true
            self.layoutIfNeeded()
        }
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations) { (finish) in
  
            }
        }else{
            animations()
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        getCommentList(1)
        self.commentTF.attributedPlaceholder = NSAttributedString(string: "说你想说的话...", attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        self.commentTF.text = ""
        self.replyId = nil
    }
    
    @objc func cancelCommentAction()
    {
        self.commentTF.resignFirstResponder()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        hiden()
    }
    
    @IBAction func replyAction(_ sender: UIButton) {
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
    
    //    MARK: - 获取评论列表
    func getCommentList(_ page: Int) {
        let request = BaseRequest()
        request.dic = [
            "tid" : tid,
            "type" : "20"
        ]
        request.page = [page,20]
        request.url = BaseURL.TopicCommentList
        request.isUser = true
        request.start { (data, error) in
            self.tableview.srf_endRefreshing()
            guard error == nil else
            {
                //执行错误信息
                return
            }
            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            self.titleLB.text = "全部评论（\(self.totalNum!)）"
            
            if self.currentPage == 1
            {
                self.dataArr.removeAll()
                
                if listData.isEmpty
                {
                }else{
                    self.tableview.reloadData()
                }
                if self.currentPage! < self.totalPage!
                {
                    self.tableview.srf_canLoadMore(true)
                }else{
                    self.tableview.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage
            {
                self.tableview.srf_canLoadMore(false)
            }
            
            self.dataArr.append(contentsOf: listData)
            self.tableview.reloadData()
        }
    }
    
    //发布评论
    func setComment()
    {
        if (self.commentTF.text?.isEmpty)!
        {
            return
        }
        
        var dic =  ["content":self.commentTF.text!, "tid":tid]
        
        if self.replyId != nil
        {
            dic["replyId"] = "\(self.replyId!)"
        }
        
        let request = BaseRequest()
        request.dic = dic
        request.url = BaseURL.TopicCommentPublic
        request.isUser = true
        request.start { (data, error) in
            
            self.isPublishingComment = false

            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            ToolClass.showToast("评论成功", .Success)
            
            self.getCommentList(1)
            self.commentTF.resignFirstResponder()
            self.commentTF.text = ""
            self.commentTF.attributedPlaceholder = NSAttributedString(string: "说你想说的话...", attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
            self.delegate?.commentSuccessIndexPath(self.indexPath)
        }
    }
    
    //点赞评论
    func supportComment(_ commentId:Int, type: Int)
    {
        let request = BaseRequest()
        request.dic = ["commentId":"\(commentId)", "type":"\(type)"]
        request.url = BaseURL.SupportTopicComment
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            
        }
    }
    
    //删除评论
    func deleteComment(_ commentId:Int)
    {
        let request = BaseRequest()
        request.dic = ["commentId":"\(commentId)"]
        request.url = BaseURL.DeleteTopicComment
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                return
            }
            ToolClass.showToast("删除成功", .Success)
            
            self.tableview.reloadData()
        }
    }
}

extension TopicCommentListView:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,TopicCommentActionDelegate
{
    
    func supportComment(_ cell: UITableViewCell, isSelect: Bool, indexPath: IndexPath) {
        var dic = self.dataArr[indexPath.row]
        dic["isSupport"] = isSelect ? 1 : 0
        var supportNum = dic["supportNum"] as! Int
        if isSelect
        {
            supportNum += 1
        }else{
            supportNum -= 1
        }
        dic["supportNum"] = supportNum
        self.dataArr[indexPath.row] = dic
        
        let commentId = dic["id"] as! Int
        
        self.supportComment(commentId, type: isSelect ? 10 : 20)
    }
    
    func tapHeadForIndex(_ indexPath: IndexPath) {
        let dic = self.dataArr[indexPath.row]
        let user = dic["user"] as! [String:Any]
        
        let fromVC = ToolClass.controller2(view: self)
        
        let vc = PersonalPageVC()
        vc.user = user
        fromVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !isPublishingComment {
           isPublishingComment = true
           setComment()
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic = dataArr[indexPath.row]
        if let _ = dic.dicValue("reply") {
            let cell = tableview.dzy_dequeueReusableCell(CommentReplyViewCell.self)!
            cell.setData(dic, indexPath: indexPath, uid: topicUid)
            cell.delegate = self
            return cell
        }else if let _ = dic.dicValue("gift") {
            let cell = tableview.dzy_dequeueReusableCell(CommentGiftCell.self)
            cell?.data = dataArr[indexPath.row]
            return cell!
        }else {
            let cell = tableview.dzy_dequeueReusableCell(CommentViewCell.self)!
            cell.setData(dic, indexPath: indexPath, uid: topicUid)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = self.dataArr[indexPath.row]
        let user = dic["user"] as! [String:Any]
        
        let uid = user["uid"] as! String
        
        if ToolClass.decryptUserId(uid) == ToolClass.decryptUserId(DataManager.userAuth())
        {
            //点击自己的评论
            let alertController = UIAlertController()
            
            let cancelAction = UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil)
            alertController.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "删除", style: .default) { (action) in
                let commentId = dic["id"] as! Int
                self.deleteComment(commentId)
                self.dataArr.remove(at: indexPath.row)
            }
            
            let cell = tableView.cellForRow(at: indexPath)
            
            alertController.popoverPresentationController?.sourceView = cell
            alertController.popoverPresentationController?.sourceRect = CGRect(x: 80, y:(cell?.na_height)!/2, width: 0.0, height: 0.0)
            
            alertController.addAction(okAction)
            
            // 顯示提示框
            ToolClass.controller2(view: self)?.present(
                alertController,
                animated: true,
                completion: nil)
            
        }else{
            // 点击他人的评价
            let commentId = dic["id"] as! Int
            
            self.replyId = commentId
            let nickname = user["nickname"] as! String
            self.commentTF.attributedPlaceholder = NSAttributedString(string: "回复@" + nickname, attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
            
            self.commentTF.becomeFirstResponder()
        }
    }
}
