//
//  TrainPlanStartView.swift
//  PPBody
//
//  Created by edz on 2019/12/30.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanStartView: UIView {
    
    private var datas: [[String : Any]] = []

    @IBOutlet weak var mTitleLB: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mTitleLB.font = dzy_FontBlod(17)
        startBtn.titleLabel?.font = dzy_FontBlod(15)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dzy_registerCellNib(RecordDetailCell.self)
    }
    
    func updateUI(_ datas: [[String : Any]]) {
        self.datas = datas
        tableView.reloadData()
    }
    
    @IBAction private func beginAction(_ sender: UIButton) {
        
    }
}

extension TrainPlanStartView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int)
        -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath)
        -> CGFloat
    {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView
            .dzy_dequeueReusableCell(RecordDetailCell.self)
        return cell!
    }
}
