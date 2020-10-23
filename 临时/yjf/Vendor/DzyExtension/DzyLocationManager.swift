//
//  DzyLocationManager.swift
//  ZHYQ-FsZc
//
//  Created by edz on 2019/1/22.
//  Copyright © 2019 dzy. All rights reserved.
//

import UIKit
import CoreLocation

enum DzyAccuracy {
    case bestForNavigation
    case best
    case tenMeters
    case hundredMeters
    case kilometer
    case threeKilometers
}

enum DzyLLTimes {
    case once
    case keep
}

struct DzyLLocationModel: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "latitude - \(latitude), longitude - \(longitude)"
    }
    
    var latitude: Double
    var longitude: Double
}

struct DzyLLCityModel {
    /// 国家
    var country: String?
    /// 省
    var province: String?
    /// 市
    var city: String?
    /// 区
    var district: String?
    /// 街
    var street: String?
    /// 门牌号
    var number: String?
    /// 地址
    var address: String?
    
    init(_ placemark: CLPlacemark) {
        self.country    = placemark.country
        self.province   = placemark.administrativeArea
        self.city       = placemark.locality
        self.district   = placemark.subLocality
        self.street     = placemark.thoroughfare
        self.number     = placemark.subThoroughfare
        self.address    = placemark.name
    }
}

class DzyLocationManager: NSObject {
    
    static let `default` = DzyLocationManager()
    
    fileprivate var manager: CLLocationManager = CLLocationManager()
    
    fileprivate var times: DzyLLTimes = .once
    /// 经纬度
    var locationHandler: ((DzyLLocationModel?)->())?
    /// 城市区
    var geoHandler: ((DzyLLCityModel) -> ())?
    /// 解码城市区失败
    var geoCancelHandler: (()->())?
    /// 状态改变的 Handler
    var changeHandler: (()->())?
    
    func initStep(_ type: DzyAccuracy = .best, times: DzyLLTimes = .once) {
        updateManagerType(type)
        self.times = times
        manager.delegate = self
        locationHandler = nil
        geoHandler = nil
        geoCancelHandler = nil
        changeHandler = nil
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        if #available(iOS 9.0, *) {
            manager.requestLocation()
        }else {
            manager.startUpdatingLocation()
        }
    }
    
    func checkIsOpenServices() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return CLLocationManager.locationServicesEnabled() &&
            (status == .authorizedAlways || status == .authorizedWhenInUse)
    }
    
    private func stop() {
        manager.stopUpdatingLocation()
    }
    
    private func updateManagerType(_ type: DzyAccuracy) {
        switch type {
        case .bestForNavigation:
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .best:
            manager.desiredAccuracy = kCLLocationAccuracyBest
        case .tenMeters:
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        case .hundredMeters:
            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .kilometer:
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
        case .threeKilometers:
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
    }
    
    ///  反编译，获取省市区
    private func geoCoderAction(_ location: CLLocation) {
        guard geoHandler != nil else {return}
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, _) in
            guard let placemarks = placemarks else {
                self.geoCancelHandler?()
                return
            }
            for placemark in placemarks {
                let model = DzyLLCityModel(placemark)
                self.geoHandler?(model)
            }
        }
    }
    
//    MARK: - 获取两个点之间的距离
    static func distanceBetweenTwoPoint(_ lat1: Double,
                                        lon1: Double,
                                        lat2: Double,
                                        lon2: Double) -> Double
    {
        let location1 = CLLocation(latitude: lat1, longitude: lon1)
        let location2 = CLLocation(latitude: lat2, longitude: lon2)
        return location1.distance(from: location2)
    }
}

extension DzyLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coordinate = location.coordinate
            if times == .once {
                locationHandler?(DzyLLocationModel(latitude: coordinate.latitude, longitude: coordinate.longitude))
                geoCoderAction(location)
                manager.stopUpdatingLocation()
            }else {
                locationHandler?(DzyLLocationModel(latitude: coordinate.latitude, longitude: coordinate.longitude))
                geoCoderAction(location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationHandler?(nil)
        dzy_log(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("change")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            changeHandler?()
        }
    }
}
