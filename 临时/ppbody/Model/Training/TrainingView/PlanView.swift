//
//  PlanView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/4/24.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import SnapKit

class PlanView: UIView
{
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var page: NaPageControl!
    
    class func instanceFromNib() -> PlanView {
        return UINib(nibName: "TrainingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlanView
    }
    
    
    override func awakeFromNib() {

        self.scrollview.delegate = self
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(courseAction(_:))))
    }
    
    @IBAction func courseAction(_ sender: UIButton) {
        let from = ToolClass.controller2(view: self)
        let vc = DataManager.isCoach() ? CoachCourseVC() : StudentCourseVC()
        from?.tabBarController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setData(_ list:[[String:Any]])
    {
        for view in self.stackview.arrangedSubviews
        {
            self.stackview.removeArrangedSubview(view)
        }
        
        if list.count == 0
        {
            for view in self.stackview.arrangedSubviews
            {
                self.stackview.removeArrangedSubview(view)
            }
            
        }else{

            if DataManager.isCoach()
            {
                for dic in list
                {
                    let item = PlanItemView.instanceFromNib()
                    item.setData(dic)
                    self.stackview.addArrangedSubview(item)
                    item.snp.makeConstraints { (make) in
                        make.width.equalTo(self.scrollview.snp.width).dividedBy(3)
                        make.height.equalToSuperview()
                    }
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
                

            }else{
                for dic in list
                {
                    let item = CoachItemView.instanceFromNib()
                    item.setData(dic)
                    self.stackview.addArrangedSubview(item)
                    item.snp.makeConstraints { (make) in
                        make.width.equalTo(self.scrollview.snp.width)
                        make.height.equalToSuperview()
                    }
                }
                
                if list.count < 2
                {
                    self.page.isHidden = true
                }else{
                    self.page.isHidden = false
                    self.page.numberOfPages = list.count
                    self.page.currentPage = 0
                }
                
            }
            
        }
    }
}

extension PlanView: UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        page.currentPage = Int(pageNumber)
    }
}


