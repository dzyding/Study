//
//  SmartQAVC.swift
//  YJF
//
//  Created by edz on 2019/8/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

enum QaIdentity: Int {
    case yjf = 0
    case user
    case time
}

private let qaKey = "DzyType"

private let qaTimeKey = "time"

class SmartQAVC: BaseVC {
    /// 文件夹路径
    private let cachePath: String = NSSearchPathForDirectoriesInDomains(
        .cachesDirectory, .userDomainMask, true).last!
    
    private var documentPath: String {
        return cachePath + "/qalist.txt"
    }

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var inputTF: UITextField!
    
    private var questions: [[String : Any]] = []
    /// 当前的日期
    private var currentTime: String?
    
    private var datas: [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "智能问答"
        initUI()
        initTime()
    }
    
    deinit {
        let json = ToolClass.toJSONString(dict: datas)
        do {
            try json.write(toFile: documentPath, atomically: true, encoding: .utf8)
        }catch {
            dzy_log(error)
        }
    }
    
    private func initUI() {
        inputTF.addTarget(self, action: #selector(editingEnd(_:)), for: .editingDidEndOnExit)
        inputTF.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        tableView.dzy_registerCellNib(SmartQaUserCell.self)
        tableView.dzy_registerCellNib(SmartQaServiceCell.self)
        tableView.dzy_registerCellNib(SmartQaTimeCell.self)
        
        view.addSubview(assView)
        assView.isHidden = true
        assView.snp.makeConstraints { (make) in
            make.height.equalTo(200.0)
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        view.addSubview(emptyView)
        emptyView.isHidden = true
        emptyView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    private func initTime() {
        do {
            let str = try String(contentsOfFile: documentPath, encoding: .utf8)
            datas = ToolClass.getArrayFromJSONString(jsonString: str) as? [[String : Any]] ?? []
            if let timeData = datas.reversed().first(
                where: {$0.intValue(qaKey) == QaIdentity.time.rawValue}
            ) {
                currentTime = timeData.stringValue(qaTimeKey)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reloadTableView()
            }
        }catch {
            dzy_log(error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    @objc private func editingEnd(_ tf: UITextField) {
        tf.resignFirstResponder()
    }
    
    @objc private func editingChanged(_ tf: UITextField) {
        guard let text = tf.text, text.count > 0 else {
            emptyView.isHidden = true
            assView.isHidden = true
            questions = []
            return
        }
        assQuestionListApi(text) { [weak self] (list) in
            self?.assView.isHidden = list.count == 0
            self?.emptyView.isHidden = list.count != 0
            self?.questions = list
            self?.assView.updateUI(list, key: text)
        }
    }
    
    //    MARK: - 添加新消息
    func appendNewData(_ data: [String : Any], type: QaIdentity) {
        var data = data
        data[qaKey] = type.rawValue
        if datas.count > 10 {
            datas.removeFirst()
        }
        datas.append(data)
    }
    
    //    MARK: - 刷新
    func reloadTableView() {
        tableView.reloadData()
        if datas.count > 0 {
            tableView.scrollToRow(
                at: IndexPath(row: datas.count - 1, section: 0),
                at: .bottom,
                animated: true
            )
        }
    }
    
    //MARK: -  发送用户消息
    private func sendUserMsg(_ data: [String : Any]) {
        // 添加时间 cell
        func addNewTime(_ time: String) {
            let timeMsg = [
                qaTimeKey : time
            ]
            appendNewData(timeMsg, type: .time)
            currentTime = time
        }
        
        guard let nowStr = dzy_date8().description
            .components(separatedBy: " ").first else {return}
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        if let currentTime = currentTime,
            let current = format.date(from: currentTime),
            let now = format.date(from: nowStr)
        {
            let result = now.compare(current)
            if result == .orderedDescending { // 大于
                addNewTime(nowStr)
            }
        }else {
            addNewTime(nowStr)
        }
        // 添加用户 cell
        appendNewData(data, type: .user)
        reloadTableView()
        
        guard let title = data.stringValue("title"),
            let cId = data.intValue("id")
        else {return}
        let yjfMsg: [String : Any] = [
            "content" : "关于\(title)的相关咨询，请点击这里",
            "title" : title,
            "id" : cId
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.appendNewData(yjfMsg, type: .yjf)
            self.reloadTableView()
        }
    }
    
    //    MARK: - api
    private func assQuestionListApi(_ key: String, complete: @escaping ([[String : Any]]) -> ()) {
        let request = BaseRequest()
        request.url = BaseURL.assQuestionList
        request.dic = ["title" : key]
        request.dzy_start { (data, _) in
            let list = data?.arrValue("list") ?? []
            complete(list)
        }
    }
    
    //    MARK: - 懒加载
    private lazy var assView: AssociateInputView = {
        let view = AssociateInputView.initFromNib(AssociateInputView.self)
        view.initUI()
        view.delegate = self
        return view
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.textColor = Font_Light
        label.font = dzy_Font(14)
        label.text = "没有找到相关内容，换个关键词试试"
        label.textAlignment = .center
        view.addSubview(label)
        
        let edg = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(edg)
        }
        return view
    }()
}

extension SmartQAVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = datas[indexPath.row]
        switch typeForIndex(indexPath.row) {
        case .yjf:
            let cell = tableView
                .dzy_dequeueReusableCell(SmartQaServiceCell.self)
            cell?.updateUI(data.stringValue("content"))
            return cell!
        case .user:
            let cell = tableView
                .dzy_dequeueReusableCell(SmartQaUserCell.self)
            cell?.updateUI(data.stringValue("title"))
            return cell!
        case .time:
            let cell = tableView
                .dzy_dequeueReusableCell(SmartQaTimeCell.self)
            if let time = data.stringValue(qaTimeKey),
                time.count > 5
            {
                let index = time.index(time.startIndex, offsetBy: 5)
                cell?.timeLB.text = String(time[index...])
            }else {
                cell?.timeLB.text = "今天"
            }
            return cell!    
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return typeForIndex(indexPath.row) == .time ? 44 : 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if typeForIndex(indexPath.row) == .yjf,
            let title = datas[indexPath.row].stringValue("title"),
            let cId = datas[indexPath.row].intValue("id")
        {
            let vc = WkWebVC(.consult(cId: cId, title: title))
            dzy_push(vc)
        }
    }
    
    private func typeForIndex(_ index: Int) -> QaIdentity {
        let data = datas[index]
        let typeInt = data[qaKey] as? Int ?? 0
        return QaIdentity(rawValue: typeInt) ?? QaIdentity.yjf
    }
}

extension SmartQAVC: AssociateInputViewDelegate {
    func inputView(_ inputView: AssociateInputView, didClickQuestion question: [String : Any]) {
        inputTF.text = nil
        inputTF.resignFirstResponder()
        assView.isHidden = true
        emptyView.isHidden = true
        sendUserMsg(question)
    }
}
