//
//  LocationSearchVC.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationSearchVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    private var dic: [String : String]

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var inputTF: UITextField!
    /// 66 16
    @IBOutlet private weak var inputViewRightLC: NSLayoutConstraint!
    /// 关键字视图 (热门搜索，历史搜索)
    @IBOutlet private weak var keysView: UIView!
    
    @IBOutlet private weak var hotLB: UILabel!
    
    @IBOutlet private weak var historyLB: UILabel!
    
    @IBOutlet private weak var hisDelBtn: UIButton!
    
    private weak var historyVlView: VarietyLabelView?
    
    init(_ dic: [String : String]) {
        self.dic = dic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listAddHeader()
        initUI()
        hotKeyApi()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.inputTF.becomeFirstResponder()
        }
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
    
//    MARK: - 显示搜索结果和隐藏搜索结果的动画
    private func showAnimate() {
        inputViewRightLC.constant = 66
        UIView.animate(withDuration: 0.25) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.keysView.alpha = 0
        }
    }
    
    private func dismissAnimate() {
        inputViewRightLC.constant = 16
        UIView.animate(withDuration: 0.25) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.keysView.alpha = 1
        }
    }

//    MARK: - 输入监听
    @objc private func editingChanged(_ tf: UITextField) {
        let count = tf.text?.count ?? 0
        if count == 0 {
            dismissAnimate()
        }
    }
    
    @objc private func editingDidEnd(_ tf: UITextField) {
        guard let key = tf.text, key.count > 0 else {return}
        dic["key"] = key
        listApi(1)
        showAnimate()
        
        var hisKeys = DataManager.locationSearchDatas() ?? []
        if !hisKeys.contains(key) {
            hisKeys.append(key)
            DataManager.saveLocationSearch(hisKeys)
        }
        
        historyVlView?.updateUI(DataManager.locationSearchDatas() ?? [])
        showOrHideHistory(false)
    }
    
//    MARK: - 删除历史记录
    @IBAction func hisDeleteAction(_ sender: Any) {
        DataManager.saveLocationSearch([])
        showOrHideHistory(true)
    }
    
//    MARK: - 隐藏、显示历史搜素
    private func showOrHideHistory(_ isHiden: Bool) {
        historyLB.isHidden = isHiden
        hisDelBtn.isHidden = isHiden
        historyVlView?.isHidden = isHiden
    }
    
    //    MARK: - 返回、取消搜索
    @IBAction func backAction(_ sender: Any) {
        dzy_pop()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        inputTF.resignFirstResponder()
        inputTF.text = nil
        dismissAnimate()
    }

    //    MAKR: - 初始化界面
    private func initUI() {
        tableView.dzy_registerCellNib(LocationGymCell.self)
        inputTF.attributedPlaceholder = LocationVCHelper
            .shearchAttPlcaeHolder()
        inputTF.addTarget(self,
                          action: #selector(editingChanged(_:)),
                          for: .editingChanged)
        // 搜索按钮
        inputTF.addTarget(self,
                          action: #selector(editingDidEnd(_:)),
                          for: .editingDidEndOnExit)
        // IQKeyBoard 的完成按钮
        inputTF.addTarget(self,
                          action: #selector(editingDidEnd(_:)),
                          for: .editingDidEnd)
    }
    
    private func initKeysView(_ hotKeys: [String]) {
        // 热门关键字
        let hotKeysFrame = CGRect(x: 16,
                                  y: hotLB.frame.maxY + 15,
                                  width: ScreenWidth - 32.0,
                                  height: 30.0)
        let hotKeysView = VarietyLabelView(hotKeys, frame: hotKeysFrame)
        hotKeysView.initSubViews()
        hotKeysView.tag = 1
        hotKeysView.delegate = self
        keysView.addSubview(hotKeysView)
        
        // 历史关键字LB
        var hisFrame = historyLB.frame
        hisFrame.origin.y = hotKeysView.frame.maxY + 18.0
        historyLB.frame = hisFrame
        
        // 删除历史记录的按钮
        var btnFrame = hisDelBtn.frame
        btnFrame.origin.x = ScreenWidth - 16.0 - btnFrame.width
        hisDelBtn.frame = btnFrame
        hisDelBtn.center.y = hisFrame.midY
        
        // 历史关键字
        let hisKeysFrame = CGRect(x: 16,
                                  y: hisFrame.maxY + 15,
                                  width: ScreenWidth - 32.0,
                                  height: 30.0)
        let hisKeys = DataManager.locationSearchDatas() ?? []
        let hisKeysView = VarietyLabelView(hisKeys, frame: hisKeysFrame)
        hisKeysView.initSubViews()
        hisKeysView.tag = 2
        hisKeysView.delegate = self
        keysView.addSubview(hisKeysView)
        self.historyVlView = hisKeysView
        
        if hisKeys.count == 0 {
            showOrHideHistory(true)
        }
    }
    
//    MARK: - Api
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.ClubList
        request.dic = dic
        request.page = [page, 20]
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
    
    func hotKeyApi() {
        guard let code = LocationManager.locationManager.cityCode else {
            initKeysView([])
            return
        }
        let request = BaseRequest()
        request.url = BaseURL.ClubSearchHot
        request.dic = ["cityCode" : code]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            (data?["hotKey"] as? [String]).flatMap({
                self.initKeysView($0)
            })
        }
    }
}

extension LocationSearchVC: VarietyLabelViewDelegate {
    func vlView(_ vlView: VarietyLabelView,
                didClickTitle title: String,
                withIndex index: Int)
    {
        inputTF.text = title
        if inputTF.isFirstResponder {
            inputTF.resignFirstResponder()
        }else {
            editingDidEnd(inputTF)
        }
        
        if vlView.tag == 1 { // 热门
            
        }else { // 历史
            
        }
    }
}

extension LocationSearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(LocationGymCell.self)
        cell?.updateUI(dataArr[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cid = dataArr[indexPath.row].stringValue("cid") {
            let vc = LocationGymVC(cid)
            dzy_push(vc)
        }else {
            ToolClass.showToast("无效的健身房信息", .Failure)
        }
    }
}

