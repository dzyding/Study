//
//  MapVC.swift
//  PPBody
//
//  Created by edz on 2018/12/6.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import Kingfisher

class MapVC: BaseVC {
    
    @IBOutlet weak var mapView: MKMapView!
    // 名字
    var name: String
    // 经度
    var lat: Double
    // 纬度
    var lon: Double
    
    private var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon)
    }
    
    private var baiduL: CLLocationCoordinate2D {
        return dzy_gdToBaidu(location)
    }
    
    init(_ name: String, _ lat: Double, lon: Double) {
        self.name = name
        self.lat = lat
        self.lon = lon
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = name
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.none, animated: true)
        
        let anno = PPAnnotation(location)
        anno.title = name
        mapView.addAnnotation(anno)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.006,
                                    longitudeDelta: 0.004)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        mapView.setCenter(location, animated: true)
    }
    
    @IBAction func alertSheetAction(_ sender: Any) {
        let textColor = dzy_HexColor(0x333333)
        let alert = UIAlertController(title: nil, message: "前往指定应用进行导航", preferredStyle: .actionSheet)
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = .light
        }
        let apple = UIAlertAction(title: "Apple 地图", style: .default) { [weak self] (_) in
            self?.appleMapAction()
        }
        apple.setTextColor(textColor)
        let baidu = UIAlertAction(title: "百度地图", style: .default) { [weak self] (_) in
            guard let sSelf = self,
                let bdurl = URL(string: "baidumap://"),
                UIApplication.shared.canOpenURL(bdurl)
            else {
                ToolClass.showToast("您尚未安装百度地图", .Failure)
                return
            }
            String(format: "baidumap://map/direction?origin={{我的位置}}&destination=%lf,%lf&mode=driving&src=%@",
                   sSelf.baiduL.latitude,
                   sSelf.baiduL.longitude,
                   sSelf.name)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap({
                URL(string: $0)
            })
            .flatMap({
                UIApplication.shared.open($0)
            })
        }
        baidu.setTextColor(textColor)
        let gaode = UIAlertAction(title: "高德地图", style: .default) { [weak self] (_) in
            guard let sSelf = self,
                let bdurl = URL(string: "iosamap://"),
                UIApplication.shared.canOpenURL(bdurl)
            else {
                ToolClass.showToast("您尚未安装高德地图", .Failure)
                return
            }
            String(format: "iosamap://navi?sourceApplication=applicationName&poiname=%@&lat=%lf&lon=%lf&dev=1", sSelf.name, sSelf.lat, sSelf.lon)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap({
                URL(string: $0)
            })
            .flatMap({
                UIApplication.shared.open($0)
            })
        }
        gaode.setTextColor(textColor)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        cancel.setTextColor(textColor)
        alert.addAction(apple)
        alert.addAction(baidu)
        alert.addAction(gaode)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func appleMapAction() {
        let loc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let current = MKMapItem.forCurrentLocation()
        let end = MKMapItem(placemark: MKPlacemark(coordinate: loc))
        end.name = name
        MKMapItem.openMaps(with: [current, end], launchOptions: [
            MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey : true
            ])
    }
}

extension MapVC: MKMapViewDelegate {
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let idf = "PPAnnotation"
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: idf)
        annotationView.annotation = annotation
        if let imageUrl = data.dicValue("user")?.stringValue("head"),
            let url = URL(string: imageUrl)
        {
            KingfisherManager.shared.downloader.downloadImage(with: url, options: [.cacheOriginalImage]) { (img, error, _, _) in
                annotationView.image = img?.kf.image(withRoundRadius: 25, fit: CGSize(width: 50, height: 50))
                annotationView.contentMode = .center
            }
        }
        annotationView.canShowCallout = true //设置弹窗
        annotationView.leftCalloutAccessoryView //左弹窗
        annotationView.rightCalloutAccessoryView //右弹窗
        
        return annotationView
    }
    */
}
