//
//  RecordView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/24.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RecordView: UIView
{
    @IBOutlet weak var page: NaPageControl!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var tipIV: UIImageView!
    
    var motionDetailList:[[String:Any]]?
    
    lazy var emptyView: UIView = {
        let emptyView = UIView(frame: self.bgView.frame)
        let iv = UIImageView(image: UIImage(named: "training_motion_empty"))
        iv.sizeToFit()
        iv.center = CGPoint(x: emptyView.na_width/2, y:  emptyView.na_height/2 + 30)
        emptyView.addSubview(iv)
        
        let txt = UILabel()
        txt.text = "赶紧记录吧！"
        txt.font = ToolClass.CustomFont(12)
        txt.textColor = Text1Color
        txt.sizeToFit()
        txt.center = CGPoint(x: emptyView.na_width/2, y:  emptyView.na_height - 30)
        emptyView.addSubview(txt)
        return emptyView
    }()
    
    class func instanceFromNib() -> RecordView {
        return UINib(nibName: "TrainingView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! RecordView
    }
    
    override func awakeFromNib() {
        
        self.scrollview.delegate = self
        
        if DataManager.firstRegister() == 1
        {
            self.tipIV.isHidden = false
            ToolClass.dispatchAfter(after: 8) {
                self.tipIV.isHidden = true
            }
        }else{
            self.tipIV.removeFromSuperview()
        }
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recordAction(_:))))
    }
    
    func setData(_ list:[[String:Any]])
    {
        for view in stackview.arrangedSubviews {
            stackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        if list.count == 0 {
            addSubview(emptyView)
            page.isHidden = true
        }else{
            if subviews.contains(emptyView) {
                emptyView.removeFromSuperview()
            }
            let pageNum = list.count/3 + (list.count%3 == 0 ?0:1)
            if pageNum<2 {
                page.isHidden = true
            }else{
                page.isHidden = false
            }
            page.numberOfPages = pageNum
            page.currentPage = 0
            
            for dic in list {
                let item = RecordItemView.instanceFromNib()
                item.setData(dic)
                item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMotionDetailAction(_:))))
                self.stackview.addArrangedSubview(item)
                item.snp.makeConstraints { (make) in
                    make.width.equalTo(self.scrollview.snp.width).dividedBy(3)
                    make.height.equalToSuperview()
                }
            }
            let offset = 3 - list.count % 3
            if offset == 3 {
                return
            }
            for _ in 0..<offset {
                let item = UIView()
                self.stackview.addArrangedSubview(item)
                item.snp.makeConstraints { (make) in
                    make.width.equalTo(self.scrollview.snp.width).dividedBy(3)
                    make.height.equalToSuperview()
                }
            }
        }
    }
    
    @objc func tapMotionDetailAction(_ tap: UITapGestureRecognizer) {
        
        let vc = ToolClass.controller2(view: self) as! TrainingVC_old
        let parent = vc.parent
        let recordDetailView = RecordDetailView.instanceFromNib()
        recordDetailView.dataArr = self.motionDetailList!
        recordDetailView.selectDate = vc.selectDate
        recordDetailView.showDetailView()
        recordDetailView.frame = (parent?.view.bounds)!
        parent?.navigationController?.view.addSubview(recordDetailView)
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
         let vc = ToolClass.controller2(view: self)
        let toVC = MotionTrainingSpaceVC()
        vc?.tabBarController?.navigationController?.pushViewController(toVC, animated: true)
    }
}

extension RecordView: UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        page.currentPage = Int(pageNumber)
    }
}

