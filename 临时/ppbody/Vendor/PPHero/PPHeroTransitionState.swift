//
//  PPHeroTransitionState.swift
//  20181120_Hero
//
//  Created by edz on 2018/11/20.
//  Copyright © 2018年 dzy. All rights reserved.
//

import Foundation


public enum PPHeroTransitionState: Int {
    // Hero is able to start a new transition
    case possible
    
    // UIKit has notified Hero about a pending transition.
    // Hero haven't started preparing.
    case notified
    
    // Hero's `start` method has been called. Preparing the animation.
    case starting
    
    // Hero's `animate` method has been called. Animation has started.
    case animating
    
    // Hero's `complete` method has been called. Transition is ended or cancelled. Hero is doing cleanup.
    case completing
}
