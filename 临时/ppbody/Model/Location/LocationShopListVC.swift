//
//  LocationShopListVC.swift
//  PPBody
//
//  Created by edz on 2019/10/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationShopListVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "商家列表"
        tableView.dzy_registerCellNib(LocationShopListCell.self)
    }

}

extension LocationShopListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(LocationShopListCell.self)
        return cell!
    }
}
