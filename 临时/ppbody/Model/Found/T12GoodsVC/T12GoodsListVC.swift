//
//  T12GoodsListVC.swift
//  PPBody
//
//  Created by edz on 2019/11/11.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class T12GoodsListVC: BaseVC {

    @IBOutlet weak var topLC: NSLayoutConstraint!
    
    @IBOutlet weak var bgTopLC: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = header
        tableView.dzy_registerCellNib(T12GoodsListCell.self)
        listApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?
            .setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?
            .setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func backAction(_ sender: Any) {
        dzy_pop()
    }
    
    //    MARK: - api
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.GoodsList
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dataArr = data?.arrValue("list") ?? []
            self.tableView.reloadData()
        }
    }

//    MARK: - 懒加载
    private lazy var header: UIView = {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 370)
        let view = UIView(frame: frame)
        view.backgroundColor = .clear
        return view
    }()
}

extension T12GoodsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(T12GoodsListCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let goodsId = dataArr[indexPath.row].intValue("id") else {
            ToolClass.showToast("无效的商品数据", .Failure)
            return
        }
        let vc = T12GoodsDetailVC(goodsId)
        dzy_push(vc)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topLC.constant = -scrollView.dzy_ofy
        bgTopLC.constant = -scrollView.dzy_ofy
    }
}
