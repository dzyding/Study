//
//  HeroCompatible.swift
//  20181120_Hero
//
//  Created by edz on 2018/11/20.
//  Copyright © 2018年 dzy. All rights reserved.
//

import Foundation

public protocol PPHeroCompatible {
    associatedtype CompatibleType
    
    var pphero: PPHeroExtension<CompatibleType> { get set }
}

public extension PPHeroCompatible {
    var pphero: PPHeroExtension<Self> {
        get { return PPHeroExtension(self) }
        set { }
    }
}

public class PPHeroExtension<Base> {
    public let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}
