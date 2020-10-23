//
//  ChangeUrlVC.swift
//  YJF
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class ChangeUrlVC: BaseVC {
    
    private var data = NSDictionary()
    
    private var keys: [Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        initUI()
    }
    
    private func initUI() {
        guard let file = Bundle.main.path(forResource: "UrlList", ofType: "plist") else {return}
        data = NSDictionary(contentsOfFile: file)!
        keys = data.allKeys
    }

    //    MARK: - 懒加载
    private lazy var tableView = initTableView()
    
    private func initTableView() -> UITableView {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }
}

extension ChangeUrlVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        let key = keys[indexPath.row]
        let value = data[key] ?? "123"
        cell?.textLabel?.text = "\(key)"
        cell?.detailTextLabel?.text = "\(value)"
        cell?.accessoryType =
            "\(value)" == HostManager.default.host ? .checkmark : .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keys[indexPath.row]
        if let value = data[key] as? String {
            HostManager.default.host = value
        }
        dismiss(animated: true, completion: nil)
    }
}
