//
//  YJFPickerSourceView.swift
//  190418_渐变
//
//  Created by edz on 2019/4/22.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum YJFPickerSourceType {
    case house
    case task
}

class YJFPickerSourceView: UIView {
    
    private var type: YJFPickerSourceType = .house
    
    private weak var tableView: UITableView?
    
    var datas: [[String : Any]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setUI()
    }
    
    var handler: ((Int, [String : Any]) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        let tableView = UITableView(frame: bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        addSubview(tableView)
        self.tableView = tableView
        
        tableView.dzy_registerCellNib(YJFPickerSourceCell.self)
    }
    
    func updateFrame(_ frame: CGRect) {
        self.frame = frame
        tableView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    func reloadData(_ datas: [[String : Any]], type: YJFPickerSourceType) {
        self.type = type
        self.datas = datas
        tableView?.reloadData()
        if datas.count > 0 {
            tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }   
    }
}

extension YJFPickerSourceView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(YJFPickerSourceCell.self)
        let data = datas[indexPath.row]
        switch type {
        case .task:
            cell?.subLabelLB.text = data.stringValue("createTime")
            cell?.labelLB.text = data.stringValue("name")
        default:
            cell?.labelLB.text = data.stringValue("houseTitle")
            cell?.subLabelLB.text = nil
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handler?(indexPath.row, datas[indexPath.row])
    }
}
