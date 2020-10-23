//
//  CityVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/19.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol CitySelectDelegate:NSObjectProtocol {
    func selectCity(_ city: String)
}

class CityVC: BaseVC {
    
    @IBOutlet weak var tableview: UITableView!
    var selectSectionArr = [Int]()
    
    weak var delegate:CitySelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "城市选择"
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        tableview.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "UITableViewHeaderFooterView")
        getCitys()
    }
    
    @objc func tapHeaderView(_ tap: UITapGestureRecognizer) {
        let tapSection = tap.view?.tag
        
        if selectSectionArr.contains(tapSection!)
        {
            selectSectionArr.remove(at: selectSectionArr.firstIndex(of: tapSection!)!)
        }else{
            selectSectionArr.append(tapSection!)
        }
        
        self.tableview.reloadSections(IndexSet(integer: tapSection!), with: UITableView.RowAnimation.automatic)
    }
    
    func getCitys()
    {
        let request = BaseRequest()
        request.url = BaseURL.Citys
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            
            self.dataArr = data!["list"] as! [[String:Any]]
            
            self.tableview.reloadData()
        }
    }
}

extension CityVC:UITableViewDelegate,UITableViewDataSource
{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectSectionArr.contains(section)
        {
            let dic = self.dataArr[section]
            let list = dic["citys"] as! [String]
            return list.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "UITableViewHeaderFooterView")
        header?.tag = section

        let dic = self.dataArr[section]
        header?.textLabel?.text = dic["province"] as? String
        header?.textLabel?.font = ToolClass.CustomFont(14)
        header?.textLabel?.textColor = UIColor.white
        header?.contentView.backgroundColor = CardColor
        header?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeaderView(_:))))
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let dic = self.dataArr[indexPath.section]
        let list = dic["citys"] as! [String]
        
        cell.textLabel?.textColor = Text1Color
        cell.textLabel?.text = list[indexPath.row]
        cell.contentView.backgroundColor = BackgroundColor
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = self.dataArr[indexPath.section]
        let list = dic["citys"] as! [String]
        
        self.delegate?.selectCity(list[indexPath.row])
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
