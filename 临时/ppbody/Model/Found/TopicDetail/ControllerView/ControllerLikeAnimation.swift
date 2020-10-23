//
//  ControllerLikeAnimation.swift
//  PPBody
//
//  Created by Nathan_he on 2018/11/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation


class ControllerLikeAnimation: NSObject {
    
    static let likeAnimation = ControllerLikeAnimation()
    
    let heartImgName = "video_tap_like"
    let heartImgWidth = 80
    let heartImgHeight = 80

    
    func createAnimationWithTouch(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let allTouches = event?.allTouches
        let touch = allTouches?.first
        
        let point = touch?.location(in: touch?.view)
        let img = UIImage(named: heartImgName)
        
        let imgV = UIImageView(frame: CGRect(x: 0, y: 0, width: heartImgWidth, height: heartImgHeight))
        imgV.image = img
        imgV.contentMode = .scaleAspectFill
        imgV.center = point!
        
        var leftOrRight = Int(arc4random()%2)
        leftOrRight = leftOrRight>0 ? leftOrRight : -1
        imgV.transform =  CGAffineTransform(rotationAngle: CGFloat(Double.pi / 9 * Double(leftOrRight)))
        
        touch!.view?.addSubview(imgV)
        
        
        UIView.animate(withDuration: 0.1, animations: {
            imgV.transform = imgV.transform.scaledBy(x: 1.2, y: 1.2)
        }) { (finish) in
            imgV.transform = imgV.transform.scaledBy(x: 0.8, y: 0.8)
            ToolClass.dispatchAfter(after: 0.3, handler: {
                self.animationToTop(imgV)
            })
        }
    }
    
    func createAnimationWithTouch(_ tap:UITapGestureRecognizer)
    {

        let point = tap.location(in: tap.view)
        let img = UIImage(named: heartImgName)
        
        let imgV = UIImageView(frame: CGRect(x: 0, y: 0, width: heartImgWidth, height: heartImgHeight))
        imgV.image = img
        imgV.contentMode = .scaleAspectFill
        imgV.center = point
        
        var leftOrRight = Int(arc4random()%2)
        leftOrRight = leftOrRight>0 ? leftOrRight : -1
        imgV.transform =  CGAffineTransform(rotationAngle: CGFloat(Double.pi / 9 * Double(leftOrRight)))
        
        tap.view?.addSubview(imgV)
        
        
        UIView.animate(withDuration: 0.1, animations: {
            imgV.transform = imgV.transform.scaledBy(x: 1.2, y: 1.2)
        }) { (finish) in
            imgV.transform = imgV.transform.scaledBy(x: 0.8, y: 0.8)
            ToolClass.dispatchAfter(after: 0.3, handler: {
                self.animationToTop(imgV)
            })
        }
    }
    
    
    func animationToTop(_ iv:UIImageView)
    {
        UIView.animate(withDuration: 1, animations: {
            iv.frame = CGRect(x: iv.frame.origin.x, y: iv.frame.origin.y - 100, width: iv.frame.size.width, height: iv.frame.size.height)
            iv.transform = iv.transform.scaledBy(x: 1.8, y: 1.8)
            iv.alpha = 0.0
        }) { (finish) in
            iv.removeFromSuperview()
        }
    }
}
