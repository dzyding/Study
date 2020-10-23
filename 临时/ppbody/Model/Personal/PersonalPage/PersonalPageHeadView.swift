//
//  PersonalPageHeadView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/21.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class PersonalPageHeadView: UICollectionReusableView {
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var stackview: UIStackView!
    
    weak var delegate: PersonalPageHeaderViewDelegate? {
        didSet{
            headerview.delegate = delegate
        }
    }
    
    class func instanceFromNib() -> PersonalPageHeadView {
        return UINib(nibName: "PersonalPageHeadView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PersonalPageHeadView
    }
    
    lazy var headerview : PersonalPageHeaderView = {
        let headerView = PersonalPageHeaderView.instanceFromNib()
        headerView.delegate = delegate
        return headerView
    }()
    
    override func awakeFromNib() {
        setupSubview()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        scrollview.addGestureRecognizer(tap)
        scrollview.isUserInteractionEnabled = true
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: tap.view)
        let rect = headerview.convert(headerview.headIV.frame, to: scrollview)
        if rect.contains(point),
            let image = headerview.headIV.image
        {
            headerview.delegate?.headAction(image)
        }
    }
    
    func setupSubview() {
        stackview.addArrangedSubview(headerview)
    }
    
    func setData(_ personal:[String:Any]) {
        if personal.isEmpty || stackview.arrangedSubviews.count > 1 {
            return
        }
        
        headerview.setData(personal)
        headerview.setNeedsLayout()
        headerview.layoutIfNeeded()
        if let gym = personal.dicValue("user")?
            .dicValue("gym")
        {
            let gymView = PersonalPageGymView.instanceFromNib()
            gymView.updateUI(gym)
            stackview.addArrangedSubview(gymView)
        }
        //他的话题列表
        let topicView = CoachHomeMoodView.instanceFromNib()
        stackview.addArrangedSubview(topicView)
    }
}
