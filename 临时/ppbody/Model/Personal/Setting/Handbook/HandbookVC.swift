//
//  Handbook.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class HandbookVC: BaseVC {
    
    @IBOutlet weak var tableview: UITableView!
    
    var selectSectionArr = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "使用手册"
        let path = Bundle.main.path(forResource:"handbook", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with:data, options:JSONSerialization.ReadingOptions.allowFragments)
        self.dataArr = json as! [[String:Any]]
        
        tableview.register(UINib(nibName: "HandbookCell", bundle: nil), forCellReuseIdentifier: "HandbookCell")
        
        tableview.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "UITableViewHeaderFooterView")
        
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
    
}

extension HandbookVC:UITableViewDelegate,UITableViewDataSource
{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectSectionArr.contains(section)
        {
            let dic = self.dataArr[section]
            let list = dic["list"] as! [[String:Any]]
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
        header?.textLabel?.text = dic["name"] as? String
        header?.textLabel?.font = ToolClass.CustomFont(10)
        header?.textLabel?.textColor = Text1Color
        header?.contentView.backgroundColor = CardColor
        header?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeaderView(_:))))
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HandbookCell", for: indexPath) as! HandbookCell
        let dic = self.dataArr[indexPath.section]
        let list = dic["list"] as! [[String:Any]]
        
        cell.setData(list[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
    }
    
}
