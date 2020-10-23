//
//  LocationManager.swift
//  PPBody
//
//  Created by Nathan_he on 2016/12/18.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit

class LocationManager : NSObject,AMapLocationManagerDelegate {
    
    static let locationManager = LocationManager()
    
    private var location:AMapLocationManager!
    
    var completeAction : (() -> Void)?
    
    private var sourceTimer: DispatchSourceTimer?
    
    var latitude = "30.491178"
    var longitude = "114.408425"
    var city = "武汉"
    var cityCode: String?
    var address = ""
    
    func configLocationManager() {
        location = AMapLocationManager()
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyHundredMeters
        location.pausesLocationUpdatesAutomatically = false
//        location.allowsBackgroundLocationUpdates = true
        location.locationTimeout = 6
        location.reGeocodeTimeout = 3        
//        printAllFonts()
    }
    
    func printAllFonts()
    {
        let fontFamilies = UIFont.familyNames
        for fontFamily in fontFamilies
        {
            _ = UIFont.fontNames(forFamilyName: fontFamily)
        }
    }
    
    
    func cleanUpAction()
    {
        location.stopUpdatingLocation()
        location.delegate = nil
    }
    
    func setCompleteLoaction(_ complete:@escaping ()->Void)
    {
        completeAction = complete
    }
    
    func startLocationTime()
    {
        let queue = DispatchQueue.global()
        sourceTimer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        sourceTimer?.schedule(deadline: .now(), repeating: .seconds(300), leeway: .milliseconds(100))
        sourceTimer?.setEventHandler{
            DispatchQueue.main.async {
                 self.reGeocodeAction()
            }
        }
        sourceTimer?.resume()
    }
    
    deinit {
        sourceTimer?.cancel()
    }
    
    func reGeocodeAction() {
        location.requestLocation(withReGeocode: true, completionBlock: {(location, regeocode, error) -> Void in
            guard error == nil, let regeocode = regeocode else {return}
            var cityname = regeocode.city == nil ? "火星" : regeocode.city
            if cityname?.hasSuffix("市") == true {
                cityname = cityname?
                    .replacingOccurrences(of: "市", with: "")
            }
            if regeocode.poiName != nil {
                self.address = regeocode.poiName ?? "未知地址"
            }else{
                self.address = regeocode.street ?? "未知地址"
            }
            self.city = cityname!
            self.cityCode = regeocode.citycode
            if let location = location {
                self.latitude = String(format: "%.6f", location.coordinate.latitude)
                self.longitude = String.init(format: "%.6f", location.coordinate.longitude)
                //自动提交更新
                if DataManager.userInfo() != nil {
                    self.updateLocation(regeocode)
                }
                print("latitude：" + self.latitude + " longitude：" + self.longitude + " 城市：" + self.city)
            }
            self.completeAction?()
        })
    }
    
    func updateLocation(_ region: AMapLocationReGeocode) {
        let request = BaseRequest()
        request.dic = [
            "latitude" : "\(self.latitude)",
            "longitude" : "\(self.longitude)",
            "province" : region.province == nil ? "" : region.province,
            "district" : region.district == nil ? "" : region.district,
            "street" : region.street == nil ? "" : region.street,
            "citycode" : region.citycode == nil ? "" : region.citycode,
            "adcode" : region.adcode == nil ? "" : region.adcode,
            "poiName" : region.poiName == nil ? "" : region.poiName,
            "formattedAddress" : region.formattedAddress == nil ? "" : region.formattedAddress,
            "city" : self.city
        ]
        request.isUser = true
        request.url = BaseURL.UpdateLocation
        request.start { (data, error) in
            
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
