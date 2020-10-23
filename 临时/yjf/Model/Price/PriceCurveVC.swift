//
//  PriceCurveVC.swift
//  YJF
//
//  Created by edz on 2019/8/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class PriceCurveVC: BaseVC {
    
    private let types = ["全部", "一居", "两居", "三居", "四居", "五居", "五居以上"]
    
    private var currentType = "全部"
    /// 小区列表
    private var comList: [[String : Any]] = []
    ///小区 ID
    private var comId: Int?
    /// 之前的搜索词
    private var oldKey: String?

    @IBOutlet private weak var inputTF: UITextField!
    
    @IBOutlet private weak var curveView: PriceCurveView!
    
    @IBOutlet weak var scrollBgView: UIView!

    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    private func initUI() {
        inputTF.attributedPlaceholder = PublicConfig.priceCurveSearchPlaceholder()
        inputTF.addTarget(
            self,
            action: #selector(editChanged(_:)),
            for: .editingChanged
        )
        
        tableView.dzy_registerCellClass(MapListCell.self)
        view.addSubview(tableView)
        scrollBgView.addSubview(scrollBtnView)
    }
    
    //    MARK: - 更新曲线图
    private func updateGrap(_ list: [[String : Any]]) {
        var keys: [String] = []
        var values: [Double] = []
        list.forEach { (data) in
            data.stringValue("num").flatMap({keys.append($0)})
            data.doubleValue("price").flatMap({values.append($0)})
        }
        guard keys.count == values.count else {return}
        curveView.updateUI(values, keys: keys, type: .normal)
    }
    
    //    MARK: - 筛选类型
    private func btnClick(_ index: Int) {
        view.endEditing(true)
        hideTableView()
        currentType = types[index]
        graphApi()
    }
    
    //    MARK: - 输入检测
    @objc private func editChanged(_ tf: UITextField) {
        comId = nil
        guard let key = tf.text, key.count > 0, key != oldKey else {
            hideTableView()
            emptyView.isHidden = false
            return
        }
        oldKey = key
        searchCommunitApi(key) { [weak self] list in
            self?.comList = list
            let height = CGFloat(min(5, list.count)) * 35.0
            self?.tableView.frame.size.height = height
            self?.tableView.reloadData()
            if !tf.text.isEorN {
                self?.showTableView()
            }
        }
    }
    
    private func selectSearchResult(_ com: [String : Any]) {
        hideTableView()
        inputTF.resignFirstResponder()
        inputTF.text = com.stringValue("name")
        comId = com.intValue("id")
        graphApi()
    }
    
    //    MARK: - tableView的动画
    private func showTableView() {
        UIView.animate(withDuration: 0.5) {
            self.tableView.alpha = 1
        }
    }
    
    private func hideTableView() {
        UIView.animate(withDuration: 0.5) {
            self.tableView.alpha = 0
        }
    }
    
    //    MARK: - api
    private func searchCommunitApi(
        _ key: String, complete: @escaping ([[String : Any]])->()
    ) {
        let request = BaseRequest()
        request.url = BaseURL.searchCommunit
        request.dic = ["key" : key]
        request.dzy_start { (data, _) in
            let list = data?.arrValue("list") ?? []
            complete(list)
        }
    }
    
    private func graphApi() {
        emptyView.isHidden = true
        if comId == nil {inputTF.text = nil}
        var dic: [String : Any] = [:]
        let layout = currentType
            .replacingOccurrences(of: "居", with: "室")
        if layout != "全部" {
            dic["layout"] = layout
        }
        if let comId = comId {
            dic["communityId"] = comId
        }
        let request = BaseRequest()
        request.url = BaseURL.comGraph
        request.dic = dic
        request.dzy_start { [weak self] (data, _) in
            let list = data?.arrValue("list") ?? []
            self?.updateGrap(list)
        }
    }
    
    //    MARK: - 懒加载
    private lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 50, width: ScreenWidth, height: 175.0)
        let tableView = UITableView(frame: frame, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.alpha = 0
        return tableView
    }()
    
    private lazy var scrollBtnView: ScrollBtnView = {
        let frame = CGRect(
            x: 10, y: 40, width: ScreenWidth - 20.0, height: 42
        )
        let view = ScrollBtnView(
            .arrange(60.0), frame: frame, block: btnClick
        )
        view.btns = types
        view.hasLine = false
        view.font = dzy_Font(13)
        view.normalColor = Font_Dark
        view.selectedColor = MainColor
        view.updateUI()
        return view
    }()
}

extension PriceCurveVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comList.count > 5 ? 5 : comList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(MapListCell.self)
        cell?.titleLB.text = comList[indexPath.row].stringValue("name")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectSearchResult(comList[indexPath.row])
    }
}
