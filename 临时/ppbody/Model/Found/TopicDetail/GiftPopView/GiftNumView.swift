//
//  GiftNumView.swift
//  PPBody
//
//  Created by edz on 2018/12/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol GiftNumViewDelegate: NSObjectProtocol {
    func selectNum(_ num: String)
    
    func diyNum()
}

typealias GiftNumModel = (String, String, Bool)

class GiftNumView: UIView {

    // 自定义按钮
    @IBOutlet weak var diyBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    static let size = CGSize(width: 150, height: 230)
    
    weak var delegate: GiftNumViewDelegate?
    
    var data: [GiftNumModel] = [
        ("666", "腿精", false),
        ("199", "蝙蝠背", false),
        ("99", "女友臂", false),
        ("66", "马甲线", false),
        ("52", "蜜桃臀", false),
        ("1", "A4腰", false)
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        diyBtn.layer.cornerRadius = diyBtn.dzy_h / 2.0
        diyBtn.layer.masksToBounds = true
        diyBtn.backgroundColor = RGB(r: 51.0, g: 50.0, b: 55.0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        tableView.dzy_registerCellNib(GiftNumCell.self)
    }
    
    @IBAction func diyNumAction(_ sender: UIButton) {
        delegate?.diyNum()
    }
}

extension GiftNumView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(GiftNumCell.self)
        cell?.model = data[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if data[indexPath.row].2 {return}
        (0..<data.count).forEach({data[$0].2 = false})
        data[indexPath.row].2 = true
        tableView.reloadData()
        delegate?.selectNum(data[indexPath.row].0)
    }
}
