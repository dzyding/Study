//
//  GymPickerView.swift
//  PPBody
//
//  Created by edz on 2019/4/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

@objc protocol GymPickerViewDelegate {
    func gympicker(_ picker: GymPickerView, didSelected data: [String : Any])
}

enum GymPickerType {
    case gym
    case coach
}

class GymPickerView: UIView {
    
    weak var delegate: GymPickerViewDelegate?

    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var type: GymPickerType = .gym {
        didSet {
            updateTitle()
        }
    }
    
    var datas: [[String : Any]] = []
    
    static func initFromNib(_ datas: [[String : Any]], type: GymPickerType) -> GymPickerView? {
        if let v = Bundle.main.loadNibNamed("GymPickerView", owner: self, options: nil)?.first as? GymPickerView {
            v.frame = {
                var height = 52.0 + 34.0 + 75.0 * CGFloat(datas.count)
                height = height > ScreenHeight / 2.0 ? ScreenHeight / 2.0 : height
                return CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
            }()
            v.datas = datas
            v.type = type
            return v
        }else {
            return nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.rowHeight = 75.0
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dzy_registerCellNib(GymPickerCell.self)
    }
    
    func updateTitle() {
        switch type {
        case .gym:
            titleLB.text = "请选择您要进入的健身房："
        case .coach:
            titleLB.text = "请选择您要预约的教练："
        }
    }
}

extension GymPickerView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(GymPickerCell.self)
        let data = datas[indexPath.row]
        switch type {
        case .gym:
            cell?.gymUpdateViews(data)
        case .coach:
            cell?.coachUpdateViews(data)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.gympicker(self, didSelected: datas[indexPath.row])
    }
}
