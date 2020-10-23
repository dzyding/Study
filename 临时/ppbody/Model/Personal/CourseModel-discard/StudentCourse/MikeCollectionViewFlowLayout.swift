//
//  MikeCollectionViewFlowLayout.swift
//  PPBody
//
//  Created by Mike on 2018/6/27.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class MikeCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let arr = self.getCopyOfAttributes(attributes: super.layoutAttributesForElements(in: rect)!)
        let centerX = (self.collectionView?.contentOffset.x)! + (self.collectionView?.bounds.width)!/2.0
        
        for attributes in arr {
            let distance = abs(attributes.center.x - centerX)
            let apartScale = distance/(self.collectionView?.bounds.size.width)!
            let scale = abs(cos(apartScale * .pi/4.0))
            attributes.transform = CGAffineTransform.init(scaleX: 1.0, y: scale)
            
        }
        return arr
    }
    
    func getCopyOfAttributes(attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes] {
        var copyArr = [UICollectionViewLayoutAttributes]()
        for attribute in attributes {
            copyArr.append(attribute.copy() as! UICollectionViewLayoutAttributes)
        }
        return copyArr
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}


