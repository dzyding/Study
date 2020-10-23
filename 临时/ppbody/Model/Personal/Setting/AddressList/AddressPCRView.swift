//
//  AddressPCRView.swift
//  PPBody
//
//  Created by edz on 2019/11/11.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum AddressLv {
    case province
    case city
    case region
}

protocol AddressPCRViewDelegate: class {
    func pcrView(_ pcrView: AddressPCRView, didSelectAddress str: String)
}

class AddressPCRView: UIView, InitFromNibEnable {
    
    weak var delegate: AddressPCRViewDelegate?
    
    private var lv: AddressLv = .province

    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    /// 省
    var province: String? {
        didSet {
            pLB.text = province
        }
    }
    
    @IBOutlet weak var pLB: UILabel!
    /// 市
    var city: String? {
        didSet {
            cLB.text = city
        }
    }
    
    @IBOutlet weak var cLB: UILabel!
    
    @IBOutlet weak var cCircleView: UIView!
    
    @IBOutlet weak var cBottomLine: UIView!
    /// 区
    var region: String? {
        didSet {
            rLB.text = region
        }
    }
    
    @IBOutlet weak var rLB: UILabel!
    
    @IBOutlet weak var rCircleView: UIView!
    /// 列表视图到顶部的距离
    @IBOutlet weak var topLC: NSLayoutConstraint!
    /// 当前数据
    private var datas: [String] = []
    
    private var allDatas: [[String : Any]] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        loadAllData()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func initUI(_ str: String) {
        let arr = str.components(separatedBy: " ")
        guard arr.count == 3 else {
            ToolClass.showToast("无效的地区数据", .Failure)
            return
        }
        province = arr[0]
        city = arr[1]
        region = arr[2]
        let temp = allDatas
            .first(where: {$0.stringValue("name") == arr[0]})?
            .arrValue("city")?
            .first(where: {$0.stringValue("name") == arr[1]})
        datas = temp?["area"] as? [String] ?? []
        msgLB.text = "请选择地区"
        updateUI(.region)
    }
    
    private func updateUI(_ lv: AddressLv) {
        self.lv = lv
        switch lv {
        case .province:
            topLC.constant = 50
        case .city:
            topLC.constant = 90
        case .region:
            topLC.constant = 130
        }
        tableView.reloadData()
    }
    
    private func loadAllData() {
        guard let path = Bundle.main.path(forResource: "province",
                                          ofType: "json")
        else {return}
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            allDatas = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String : Any]] ?? []
            datas = allDatas.compactMap({$0.stringValue("name")})
        }catch {
            dzy_log(error)
        }
    }
    
    private func loadCurrentData(_ str: String?,
                                 lv: AddressLv)
    {
        switch lv {
        case .city:
            guard let pname = province else {break}
            datas = allDatas
                .first(where: {$0.stringValue("name") == pname})?
                .arrValue("city")?
                .compactMap({$0.stringValue("name")}) ?? []
            if datas.count == 1 {
                selectCityAction(datas.first ?? "")
                return
            }
        case .region:
            guard let pname = province,
                let cname = city
            else {break}
            let temp = allDatas
                .first(where: {$0.stringValue("name") == pname})?
                .arrValue("city")?
                .first(where: {$0.stringValue("name") == cname})
            datas = temp?["area"] as? [String] ?? []
        default:
            break
        }
        updateUI(lv)
    }
    
    //    MAKR: - 取消
    @IBAction func cancelAction(_ sender: UIButton) {
        (superview as? DzyPopView)?.hide()
    }
    
    //    MARK: - 重新选择省份、城市
    @IBAction func updateProvinceAction(_ sender: UIButton) {
        province = nil
        city = nil
        region = nil
        lv = .province
        datas = allDatas.compactMap({$0.stringValue("name")})
        topLC.constant = 50.0
        tableView.reloadData()
    }
    
    @IBAction func updateCityAction(_ sender: UIButton) {
        guard let pname = province else {return}
        city = nil
        region = nil
        lv = .city
        selectProvinceAction(pname)
    }
    
    //    MAKR: - 选择省份、城市
    private func selectProvinceAction(_ str: String) {
        province = str
        lv = .city
        msgLB.text = "请选择城市"
        loadCurrentData(str, lv: .city)
    }
    
    private func selectCityAction(_ str: String) {
        city = str
        lv = .region
        msgLB.text = "请选择地区"
        loadCurrentData(str, lv: .region)
    }
}

extension AddressPCRView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default,
                                   reuseIdentifier: "Cell")
        }
        let color = RGBA(r: 51.0, g: 51.0, b: 51.0, a: 1)
        cell?.textLabel?.font = dzy_Font(14)
        cell?.textLabel?.textColor = color
        cell?.textLabel?.text = datas[indexPath.row]
        cell?.backgroundColor = .white
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str = datas[indexPath.row]
        switch lv {
        case .province:
            selectProvinceAction(str)
        case .city:
            selectCityAction(str)
        case .region:
            region = str
            (superview as? DzyPopView)?.hide()
            guard let pname = province, let cname = city else {return}
            let result = "\(pname) \(cname) \(str)"
            delegate?.pcrView(self, didSelectAddress: result)
        }
    }
}
