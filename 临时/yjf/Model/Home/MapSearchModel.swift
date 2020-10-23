//
//  MapSearchModel.swift
//  YJF
//
//  Created by edz on 2019/7/9.
//  Copyright © 2019 灰s. All rights reserved.
//

import Foundation

struct MapSearchModel {
    
    static var zero: MapSearchModel {
        return MapSearchModel(
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            rbLoc: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )
    }
    
    let ltLoc: CLLocationCoordinate2D
    let rbLoc: CLLocationCoordinate2D
    
    private var laRange:ClosedRange<CLLocationDegrees> {
        return rbLoc.latitude...ltLoc.latitude
    }
    
    private var loRange:ClosedRange<CLLocationDegrees> {
        return ltLoc.longitude...rbLoc.longitude
    }
    
    init(_ ltLoc: CLLocationCoordinate2D, rbLoc: CLLocationCoordinate2D) {
        self.ltLoc = ltLoc
        self.rbLoc = rbLoc
    }
    
    func contain(_ model: MapSearchModel) -> Bool {
        return laRange.contains(model.ltLoc.latitude) &&
            laRange.contains(model.rbLoc.latitude) &&
            loRange.contains(model.ltLoc.longitude) &&
            loRange.contains(model.rbLoc.longitude)
    }
    
    func add(_ model: MapSearchModel) -> MapSearchModel {
        let ltLoc = CLLocationCoordinate2D(
            latitude: max(self.ltLoc.latitude, model.ltLoc.latitude),
            longitude: min(self.ltLoc.longitude, model.ltLoc.longitude)
        )
        let rbLoc = CLLocationCoordinate2D(
            latitude: min(self.rbLoc.latitude, model.rbLoc.latitude),
            longitude: max(self.rbLoc.longitude, model.rbLoc.longitude)
        )
        return MapSearchModel(ltLoc, rbLoc: rbLoc)
    }
}
