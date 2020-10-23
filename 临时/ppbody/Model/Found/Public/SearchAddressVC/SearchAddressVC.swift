//
//  SearchVC.swift
//  ZAJA_Agent
//
//  Created by Nathan_he on 2016/12/11.
//  Copyright © 2016年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit

protocol SelectAddressDelegate: NSObjectProtocol {
    func selectAddress(_ address : Dictionary<String, String>)
}

class SearchAddressVC : BaseVC,AMapSearchDelegate
{
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchTV: UITableView!
    
    weak var delegate : SelectAddressDelegate?
    
    var dataMapArr = [AMapTip]()
    var aroundArr = [AMapPOI]()
    var searchAPI: AMapSearchAPI!
    var currentRequest: AMapInputTipsSearchRequest?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "所在位置"
        
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        self.searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let head = SearchAddressHead.instanceFromNib()
        head.delegate = self.delegate
        self.tableview.tableHeaderView = head
        
        self.tableview.register(UINib(nibName: "SearchAddressCell", bundle: nil), forCellReuseIdentifier: "SearchAddressCell")
        
        initSearch()
        searchAroundPOI()
        
        self.searchTV.register(UINib(nibName: "SearchAddressCell", bundle: nil), forCellReuseIdentifier: "SearchAddressCell")
 
        
    }
    
    func initSearch() {
        searchAPI = AMapSearchAPI()
        searchAPI.delegate = self
    }
    
    //搜索附近的
    func searchAroundPOI()
    {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(NumberFormatter().number(from: LocationManager.locationManager.latitude)!.floatValue), longitude: CGFloat(NumberFormatter().number(from: LocationManager.locationManager.longitude)!.floatValue))
        request.types = "12"
        searchAPI.aMapPOIAroundSearch(request)
    }
    
    //MARK: - Action
    
    func searchTip(withKeyword keyword: String?) {
        
        if keyword == nil || keyword! == "" {
            self.searchTV.isHidden = true
            return
        }
        self.searchTV.isHidden = false

        let request = AMapInputTipsSearchRequest()
        request.keywords = keyword
        request.city = LocationManager.locationManager.city
        request.types = "12"
        request.cityLimit = true
        
        currentRequest = request
        searchAPI.aMapInputTipsSearch(request)
        
        dataMapArr.removeAll()
        tableview.reloadData()
        
    }
    
    //MARK: - AMapSearchDelegate
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
      
    }
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        
        if currentRequest == nil || currentRequest! != request {
            return
        }
        
        if response.count == 0 {
            return
        }
        
        dataMapArr.removeAll()
        for aTip in response.tips {
            //过滤垃圾数据
            if (aTip.uid != "" && aTip.location != nil && aTip.name != "")
            {
               dataMapArr.append(aTip)
            }
        }
        searchTV.reloadData()
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!)
    {
        if response.count == 0 {
            return
        }
        
        aroundArr.removeAll()
        for aPois in response.pois {
            //过滤垃圾数据
            if (aPois.uid != "" && aPois.location != nil && aPois.name != "")
            {
                aroundArr.append(aPois)
            }
        }
        tableview.reloadData()
    }
    
    
    @objc func textFieldDidChange(_ textfield : UITextField)
    {
        searchTip(withKeyword: textfield.text)
    }
}
extension SearchAddressVC : UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.tableview ? aroundArr.count : dataMapArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchAddressCell", for: indexPath) as! SearchAddressCell
        cell.selectionStyle = .none
        
        var nameText = ""
        var addressText = ""

        if tableView == self.tableview
        {
            nameText = aroundArr[indexPath.row].name
            addressText = aroundArr[indexPath.row].address
        }else
        {
            nameText = dataMapArr[indexPath.row].name
            addressText = dataMapArr[indexPath.row].address
        }

        if nameText.contains(self.searchTF.text!)
        {
            let range = (nameText as NSString).range(of: self.searchTF.text!)
            let attributedString = NSMutableAttributedString(string:nameText)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: YellowMainColor , range: range)

            cell.nameLB.attributedText = attributedString
        }else{
            cell.nameLB.text = nameText
        }

        cell.addressLB.text = addressText
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var dataDic = [String:String]()
        
        if tableView == self.tableview {
            let aroundPOI = aroundArr[indexPath.row]
            dataDic = ["uid":aroundPOI.uid,"name":aroundPOI.name,"latitude":"\(aroundPOI.location.latitude)","longitude":"\(aroundPOI.location.longitude)"]
        }else{
            let mapTip = dataMapArr[indexPath.row]
            dataDic = ["uid":mapTip.uid,"name":mapTip.name,"latitude":"\(mapTip.location.latitude)","longitude":"\(mapTip.location.longitude)"]
        }
        
        self.delegate?.selectAddress(dataDic)
        self.navigationController?.popViewController(animated: true)
    }
}
