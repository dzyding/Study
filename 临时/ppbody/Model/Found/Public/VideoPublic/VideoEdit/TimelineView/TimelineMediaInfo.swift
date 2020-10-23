//
//  TimelineMediaInfo.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

enum TimelineMediaInfoType: Int {
    case video
    case photo
}

class TimelineMediaInfo: NSObject {
    
    var mediaType:TimelineMediaInfoType?
    var path:String?
    var duration:CGFloat?
    var startTime:CGFloat?
    var rotate:Int?
}
