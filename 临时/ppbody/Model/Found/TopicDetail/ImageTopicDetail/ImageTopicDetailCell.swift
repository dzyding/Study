//
//  ImageTopicDetailCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class ImageTopicDetailCell: UICollectionViewCell {
    
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var pageLB: UILabel!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    
    weak var delegate:TopicDetailActionDelegate?
    
    var tid:String = ""
    var dataTopic:[String:Any]?
    
    var indexPath:IndexPath!
    
    lazy var controllerview: ControllerView = {
        
        let controllerview = ControllerView.instanceFromNib()
        controllerview.delegate = self
        
        return controllerview
    }()
    
    override func awakeFromNib() {
        scrollview.delegate = self
        self.addSubview(self.controllerview)
        
        if IS_IPHONEX
        {
            self.topMargin.constant = 54
        }
        
        self.controllerview.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-SafeBottom)
        }
        
        let tapDouble=UITapGestureRecognizer(target:self,action:#selector(tapZanAction(_:)))
        tapDouble.numberOfTapsRequired = 2
        tapDouble.numberOfTouchesRequired = 1
        self.scrollview.addGestureRecognizer(tapDouble)
    }
    
    @objc func tapZanAction(_ tap: UITapGestureRecognizer)
    {
        ControllerLikeAnimation.likeAnimation.createAnimationWithTouch(tap)
        
        if !self.controllerview.supportBtn.isSelected
        {
            self.controllerview.supportAction(self.controllerview.supportBtn)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == nil
        {
            return nil
        }
        let scrollviewPoint = self.controllerview.convert(point, from: self.contentView)
        
        if !self.controllerview.isContainPoint(scrollviewPoint, with: event)
        {
            return self.scrollview
        }
        return result
    }
    
    func setData(_ dic: [String:Any], indexPath:IndexPath)
    {
        
        self.indexPath = indexPath
        
        self.dataTopic = dic
        
        tid = dic["tid"] as! String
        
        for iv in self.stackview.arrangedSubviews
        {
            self.stackview.removeArrangedSubview(iv)
        }
        
        let imgArr = dic["imgs"] as! [String]
        
//        if imgArr.count == 1
//        {
//            self.pageLB.isHidden = true
//        }else{
//            self.pageLB.isHidden = false
//        }
        
        self.pageLB.text = "1/\(imgArr.count)"
        
        
        for path in imgArr {
            let view = UIView(frame:self.bounds)
            view.backgroundColor = BackgroundColor
            let img = UIImageView()
            view.addSubview(img)
            img.setCoverImageUrl(path) { (result) in
                switch result {
                case .success(let result):
                    let image = result.image
                    img.na_size = CGSize(width: ScreenWidth,
                                         height: image.size.height * ScreenWidth / image.size.width)
                    img.center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2)
                case .failure(let error):
                    print(error)
                }
            }
            
            self.stackview.addArrangedSubview(view)
            view.snp.makeConstraints { (make) in
                make.width.equalTo(self.scrollview.snp.width)
                make.height.equalTo(self.scrollview.snp.height)
            }
        }
        self.controllerview.setData(dic)
    }
}

extension ImageTopicDetailCell:UIScrollViewDelegate,ControllerViewActionDelegate
{
    func giftAction() {
        self.delegate?.giftAction(indexPath)
    }
    
    func commentShowAction() {
        self.delegate?.commentShowAction(tid,indexPath: self.indexPath)
    }
    
    func detailAction() {
        self.delegate?.detailAction(self.dataTopic!)
    }
    
    func commentAction() {
        self.delegate?.commentAction(tid, indexPath: self.indexPath)
        
    }
    
    func shareAction() {
        self.delegate?.shareAction(tid,indexPath: self.indexPath)
    }
    
    func supportAction(_ isSelect: Bool) {
        self.delegate?.supportAction(tid, isSupport: isSelect,indexPath: self.indexPath)
    }
    
    func personalPage() {
        self.delegate?.personalPage(indexPath: self.indexPath)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.na_width)
        let totalPage = Int(scrollView.contentSize.width / scrollView.na_width)
        self.pageLB.text = "\(currentPage + 1)/\(totalPage)"
    }
}
