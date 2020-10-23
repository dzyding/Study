//
//  MyCoachView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol MyCoachViewTapDelegate:NSObjectProtocol {
    func tapCoachView(_ dic:[String:Any])
}

class MyCoachView: UIView, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var page: NaPageControl!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    
    var dataArr = [[String:Any]]()

    lazy var emptyView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "personal_tribe_empty"))
        iv.sizeToFit()
        iv.center = scrollview.center
        return iv
    }()
    
    weak var delegate:MyCoachViewTapDelegate?
    
    class func instanceFromNib() -> MyCoachView {
        return UINib(nibName: "MyCoachView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MyCoachView
    }
    
    deinit {
        deinitObservers()
    }
    
    override func awakeFromNib() {
        
        self.scrollview.delegate = self
        self.loadApi()
        
        //成为教练学员的时候 发现部落板块
        registObservers([
            Config.Notify_BeCoachMember
        ]) { [weak self] (_) in
            self?.loadApi()
        }
    }
    
    func loadApi() {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.MyCoach
        request.start { (data, error) in
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataArr = data?["list"] as! Array<Dictionary<String,Any>>
            
            self.setData(self.dataArr)
        }
    }
    
    
    func setData(_ list:[[String:Any]])
    {
        
        for view in self.stackview.arrangedSubviews
        {
            self.stackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if list.count == 0
        {
            
            self.addSubview(self.emptyView)
            
            self.page.isHidden = true
        }else{
            if self.subviews.contains(self.emptyView)
            {
                self.emptyView.removeFromSuperview()
            }
            let pageNum = list.count/3 + (list.count%3 == 0 ?0:1)
            if pageNum<2
            {
                self.page.isHidden = true
            }else{
                self.page.isHidden = false
            }
            self.page.numberOfPages = pageNum
            self.page.currentPage = 0
            
            
            for i in 0..<list.count
            {
                let dic = list[i]
                let item = RecordItemView.instanceFromNib()
                item.setCoachData(dic)
                item.tag = i
                self.stackview.addArrangedSubview(item)
                item.snp.makeConstraints { (make) in
                    make.width.equalTo(self.scrollview.snp.width).dividedBy(3)
                    make.height.equalToSuperview()
                }
                item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCoachView(_:))))
            }
            
            let offset = 3 - list.count % 3
            
            if offset == 3
            {
                return
            }
            
            for _ in 0..<offset
            {
                let item = UIView()
                self.stackview.addArrangedSubview(item)
                item.snp.makeConstraints { (make) in
                    make.width.equalTo(self.scrollview.snp.width).dividedBy(3)
                    make.height.equalToSuperview()
                }
            }
        }
    }
    
    @objc func tapCoachView(_ tap: UITapGestureRecognizer)
    {
        let index = tap.view?.tag
        let dic = self.dataArr[index!]
        self.delegate?.tapCoachView(dic)
    }
}

extension MyCoachView: UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        page.currentPage = Int(pageNumber)
    }
}
