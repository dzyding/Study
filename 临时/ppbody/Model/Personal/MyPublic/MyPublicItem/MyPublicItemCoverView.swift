//
//  MyPublicItenCoverVIew.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MyPublicItemCoverView: UIView
{
    
    lazy var centerIV:UIImageView = {
        let icon = UIImageView(image: UIImage(named: "publish_icon_my"))
        self.addSubview(icon)
//        icon.center = CGPoint(x: self.na_width/2, y: self.na_height/2)
        icon.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        icon.contentMode = UIView.ContentMode.center
        return icon
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func removeAllChilds()
    {
        for view in self.subviews
        {
            view.removeFromSuperview()
        }
    }
    
    //多张图片
    func setImages(_ imgs:[String])
    {

        self.centerIV.isHidden = true

        switch imgs.count {
        case 0:
            break
        case 1:
            getChildNum(1)
            let iv = self.subviews[0] as! UIImageView
            iv.setCoverImageUrl(imgs[0])
            iv.frame = self.bounds
            break
        case 2:
            
            getChildNum(2)
            
            let iv1 = self.subviews[0] as! UIImageView
            iv1.setCoverImageUrl(imgs[0])
            iv1.frame = CGRect(x: 0, y: 0, width: self.na_width/2, height: self.na_height)
            
            let iv2 = self.subviews[1] as! UIImageView
            iv2.setCoverImageUrl(imgs[1])
            iv2.frame = CGRect(x: self.na_width/2+1, y: 0, width: self.na_width/2-1, height: self.na_height)
            break
        case 3:
            
            getChildNum(3)
            
            let iv1 = self.subviews[0] as! UIImageView
            iv1.setCoverImageUrl(imgs[0])
            iv1.frame = CGRect(x: 0, y: 0, width: self.na_width/2, height: self.na_height)
            
            let iv2 = self.subviews[1] as! UIImageView
            iv2.setCoverImageUrl(imgs[1])
            iv2.frame = CGRect(x: self.na_width/2+1, y: 0, width: self.na_width/2-1, height: self.na_height/2)
            
            let iv3 = self.subviews[2] as! UIImageView
            iv3.setCoverImageUrl(imgs[2])
            iv3.frame = CGRect(x: self.na_width/2+1, y: self.na_height/2 + 1, width: self.na_width/2-1, height: self.na_height/2 - 1)
            break
        default:
            getChildNum(4)
            let iv1 = self.subviews[0] as! UIImageView
            iv1.setCoverImageUrl(imgs[0])
            iv1.frame = CGRect(x: 0, y: 0, width: self.na_width/2, height: self.na_height/2)
            
            let iv2 = self.subviews[1] as! UIImageView
            iv2.setCoverImageUrl(imgs[1])
            iv2.frame = CGRect(x: 0, y: self.na_height/2 + 1, width: self.na_width/2, height: self.na_height/2 - 1)
            
            let iv3 = self.subviews[2] as! UIImageView
            iv3.setCoverImageUrl(imgs[2])
            iv3.frame = CGRect(x: self.na_width/2+1, y: 0, width: self.na_width/2 - 1, height: self.na_height/2 )
            
            let iv4 = self.subviews[3] as! UIImageView
            iv4.setCoverImageUrl(imgs[3])
            iv4.frame = CGRect(x: self.na_width/2+1, y: self.na_height/2 + 1, width: self.na_width/2 - 1, height: self.na_height/2 - 1)
            break
  
        }
    
        
    }
    
    //视频封面
    func setVideoCover(_ cover: String)
    {
        
        self.centerIV.image = UIImage(named: "video_play")
        self.centerIV.isHidden = false

        getChildNum(1)

        let iv = self.subviews[0] as! UIImageView
        iv.setCoverImageUrl(cover)
        iv.frame = self.bounds
    }
    
    //今天拍摄
    func setTodayCamera()
    {
        
        self.centerIV.isHidden = false
        self.centerIV.image = UIImage(named: "publish_icon_my")


        getChildNum(0)
    }
    
    func imageView()->UIImageView
    {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }
    
    func getChildNum(_ n: Int)
    {
        var total = self.subviews.count
        total = self.subviews.contains(self.centerIV) ? (total - 1) : total
        
        if total < n
        {
            for _ in 0..<(n-total)
            {
                self.addSubview(imageView())
            }
        }else if total > n
        {
            for _ in 0..<(total - n)
            {
                self.subviews[0].removeFromSuperview()
            }
        }
        
        self.bringSubviewToFront(self.centerIV)

    }
}
