//
//  HouseDetailMapView.swift
//  YJF
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import AMapFoundationKit

@objc protocol HouseDetailMapViewDelegate {
    func mapView(_ mapView: HouseDetailMapView, didClickNaviBtn btn: UIButton)
}

class HouseDetailMapView: UIView {
    
    weak var delegate: HouseDetailMapViewDelegate?
    
    @IBOutlet private weak var mapView: MAMapView!
    
    @IBOutlet private weak var dhBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initMapView() {
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.maxZoomLevel = 15
        mapView.zoomLevel = 12
        mapView.isUserInteractionEnabled = true
    }
    
    func updateUI(_ location: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            self.mapView.setCenter(location, animated: false)
            let anno = MAPointAnnotation()
            anno.coordinate = location
            self.mapView.addAnnotation(anno)
        }
    }
    @IBAction private func dhAction(_ sender: UIButton) {
        delegate?.mapView(self, didClickNaviBtn: sender)
    }
}

extension HouseDetailMapView: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        let indetifier = "annotationReuseIndetifier"
        var annoView = mapView
            .dequeueReusableAnnotationView(withIdentifier: indetifier) as? CustomMapAnnotationView
        if annoView == nil {
            annoView = CustomMapAnnotationView(annotation: annotation, reuseIdentifier: indetifier)
        }
        annoView?.centerOffset = CGPoint(x: 0, y: -23)
        return annoView
    }
}
