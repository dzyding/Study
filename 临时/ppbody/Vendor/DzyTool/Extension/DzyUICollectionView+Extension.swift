//
//  DzyCollectionView+Extension.swift
//  PPBody
//
//  Created by edz on 2018/12/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dzy_registerCellFromNib<T: UICollectionViewCell>(_ cls:T.Type) {
        let name = String(describing: cls)
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forCellWithReuseIdentifier: name)
    }
    
    func dzy_registerCellFromClass<T: UICollectionViewCell>(_ cls:T.Type) {
        let name = String(describing: cls)
        register(T.self, forCellWithReuseIdentifier: name)
    }
    
    func dzy_registerHeaderFromNib<T: UICollectionReusableView>(_ cls: T.Type) {
        let name = String(describing: cls)
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: name)
    }
    
    func dzy_registerFooterFromNib<T: UICollectionReusableView>(_ cls: T.Type) {
        let name = String(describing: cls)
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: name)
    }
    
    func dzy_dequeueCell<T: UICollectionViewCell>(_ cls:T.Type, _ index: IndexPath) -> T? {
        let name = String(describing: cls)
        return dequeueReusableCell(withReuseIdentifier: name, for: index) as? T
    }
    
    func dzy_dequeueHeader<T: UICollectionReusableView>(_ cls:T.Type, _ index: IndexPath) -> T? {
        let name = String(describing: cls)
        return dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: name,
            for: index) as? T
    }
    
    func dzy_dequeueFooter<T: UICollectionReusableView>(_ cls:T.Type, _ index: IndexPath) -> T? {
        let name = String(describing: cls)
        return dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: name,
            for: index) as? T
    }
}
