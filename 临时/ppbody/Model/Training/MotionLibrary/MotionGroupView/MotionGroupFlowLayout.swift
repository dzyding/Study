//
//  MotionGroupFlowLayout.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class MotionGroupFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width:  self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.size.height)
        // 目标区域中包含的cell
        let attriArray = super.layoutAttributesForElements(in: targetRect)! as [UICollectionViewLayoutAttributes]
        // collectionView落在屏幕中点的x坐标
        let horizontalCenterX = proposedContentOffset.x + (self.collectionView!.bounds.width / 2.0)
        var offsetAdjustment = CGFloat(MAXFLOAT)
        for layoutAttributes in attriArray {
            let itemHorizontalCenterX = layoutAttributes.center.x
            // 找出离中心点最近的
            if(abs(itemHorizontalCenterX-horizontalCenterX) < abs(offsetAdjustment)) {
                offsetAdjustment = itemHorizontalCenterX-horizontalCenterX
            }
        }
        
        //返回collectionView最终停留的位置
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    let ActiveDistance : CGFloat = 400 //垂直缩放除以系数
    let ScaleFactor : CGFloat = 0.5     //缩放系数  越大缩放越大
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let array = super.layoutAttributesForElements(in: rect)
        var visibleRect = CGRect()
        visibleRect.origin = self.collectionView!.contentOffset
        visibleRect.size = self.collectionView!.bounds.size
        
        for attributes in array! {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = abs(distance / ActiveDistance)
            var zoom = 1 - ScaleFactor * normalizedDistance
            zoom = zoom < 0.8 ? 0.8: zoom
            attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)

            //            let alpha = 1 - normalizedDistance
            //            attributes.alpha = alpha
        }
        return array
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        //滑动放大缩小  需要实时刷新layout
        return true
    }
}
