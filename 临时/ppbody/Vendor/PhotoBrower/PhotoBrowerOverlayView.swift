//
//  PhotoBrowerOverlayView.swift
//  ZAJA_Agent
//
//  Created by Nathan_he on 2017/2/13.
//  Copyright © 2017年 Nathan_he. All rights reserved.
//

import Foundation

protocol PhotoBrowerActionDelegate {
    func deleteAction(_ index: Int)
}

class PhotoBrowerOverlayView : UIView
{
    @IBOutlet weak var coverBtn: UIButton!
    @IBOutlet weak var numLB: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
     weak var photosViewController: INSPhotosViewController?
    
    var delegate: PhotoBrowerActionDelegate?
    
    var selectIndex = 0
    
    var currentIndex = 0
    
    class func instanceFromNib() -> PhotoBrowerOverlayView {
        return UINib(nibName: "PhotoBrowerOverlayView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PhotoBrowerOverlayView
    }
    
    // Pass the touches down to other views
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) , hitView != self {
            return hitView
        }
        return nil
    }
    @IBAction func dismissAction(_ sender: Any) {
        photosViewController?.dismiss(animated: true, completion: nil)
    }
    
    //删除事件
    @IBAction func deleteAction(_ sender: Any) {
        
        //传递删除事件
        delegate?.deleteAction(currentIndex)
        
        //删除被设为封面的图片
        if currentIndex == selectIndex
        {
            selectIndex = 0
//            delegate?.coverAction(selectIndex)
        }
        photosViewController?.deletePhoto((photosViewController?.currentPhoto)!)
    }
    
    
    
    func showEditTool()
    {
        self.deleteBtn.isHidden = false
        self.coverBtn.isHidden = false
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        if newSuperview == nil{
            return
        }
        
        currentIndex = (photosViewController?.dataSource.indexOfPhoto((photosViewController?.currentPhoto)!))!
        
        if selectIndex == currentIndex
        {
            self.coverBtn.isSelected = true
        }
        
        if photosViewController?.dataSource.numberOfPhotos == 1
        {
            numLB.isHidden = true
        }else{
            numLB.text = String(format:NSLocalizedString("%d / %d",comment:""), currentIndex + 1, (photosViewController?.dataSource.numberOfPhotos)!)
        }
    }
}

extension PhotoBrowerOverlayView : INSPhotosOverlayViewable
{
    
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        
        if let photosViewController = self.photosViewController {
            if let index = photosViewController.dataSource.indexOfPhoto(photo) {
                numLB.text = String(format:NSLocalizedString("%d / %d",comment:""), index+1, photosViewController.dataSource.numberOfPhotos)
                
                currentIndex = index
                
                if index == selectIndex
                {
                    self.coverBtn.isSelected = true
                }else
                {
                    self.coverBtn.isSelected = false
                }
            }
        }
    }
    func setHidden(_ hidden: Bool, animated: Bool) {
        if self.isHidden == hidden {
            return
        }
        
        if animated {
            self.isHidden = false
            self.alpha = hidden ? 1.0 : 0.0
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
            }, completion: { result in
                self.alpha = 1.0
                self.isHidden = hidden
            })
        } else {
            self.isHidden = hidden
        }
    }
}

