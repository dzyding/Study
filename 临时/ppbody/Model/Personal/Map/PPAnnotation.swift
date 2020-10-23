//
//  PPAnnotation.swift
//  PPBody
//
//  Created by edz on 2018/12/6.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PPAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var subtitle: String?
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
