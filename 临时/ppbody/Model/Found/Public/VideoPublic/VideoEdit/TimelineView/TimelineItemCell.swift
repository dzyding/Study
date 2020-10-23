//
//  TimelineItemCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TimelinePercent: NSObject
{
    var leftPercent:CGFloat!
    var rightPercent:CGFloat!
    var color:UIColor!
}

class TimelineItemCell: UICollectionViewCell {
    
    var mappedBeginTime:CGFloat!
    var mappedEndTime: CGFloat!
    var imageView: UIImageView!
    
    private var greyView: UIView!
    var greyViews = [UIView]()
    var percents = [TimelinePercent]()
    var filterPercents = [TimelinePercent]()
    var filterViews = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        greyView = UIView(frame: CGRect.zero)
        self.addSubview(greyView)
        greyView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        greyView.isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.bounds = self.bounds
    }
    
    func refreshGreyviews()
    {
        for percent in self.percents
        {
            let x = percent.leftPercent * self.na_width
            let width = (percent.rightPercent - percent.leftPercent) * self.na_width
            let frame = CGRect(x: x, y: 0, width: width, height: self.na_height)
            let filterView = UIView(frame: frame)
            filterView.backgroundColor = percent.color
            self.addSubview(filterView)
            self.filterViews.append(filterView)
        }
    }
    
    func refreshFilterviews()
    {
        for percent in self.filterPercents
        {
            let x = percent.leftPercent * self.na_width
            let width = (percent.rightPercent - percent.leftPercent) * self.na_width
            let frame = CGRect(x: x, y: 0, width: width, height: self.na_height)
            let filterView = UIView(frame: frame)
            filterView.backgroundColor = percent.color
            self.addSubview(filterView)
            self.filterViews.append(filterView)
        }
    }
    
    func setMappedBeginTime(_ beginTime:CGFloat, endTime :CGFloat, image:UIImage?,percents:[TimelinePercent], filterPercents:[TimelinePercent])
    {
        self.mappedBeginTime = beginTime
        self.mappedEndTime = endTime
        self.imageView.image = image
        
        self.percents.removeAll()
        self.percents.append(contentsOf: percents)
        self.greyViews.forEach { (item) in
            item.removeFromSuperview()
        }
        self.greyViews.removeAll()
        
        self.refreshGreyviews()
        
        self.filterPercents.removeAll()
        self.filterPercents.append(contentsOf: filterPercents)
        self.filterViews.forEach { (item) in
            item.removeFromSuperview()
        }
        self.filterViews.removeAll()
        
        self.refreshFilterviews()
    }
}
