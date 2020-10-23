//
//  PlanSelectMotionVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import HBDNavigationBar

protocol PlanSelectMotionDelegate: class {
    func returnMotions(_ data: [[String:Any]])
}

enum SelectMotionType {
    /// 计划
    case newPlan
    /// 自主训练
    case one
    /// 编辑
    case edit
}

class PlanSelectMotionVC: BaseVC, BaseRequestProtocol {
    
    private let type: SelectMotionType
    
    var re_listView: UIScrollView {
        return tableview
    }
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var motionView: MotionGroupView!
    
    private var currentCode = "MG10000"
    
    var sMotionArr = [[String:Any]]()//选中的动作
    
    weak var delegate:PlanSelectMotionDelegate?
    
    init(_ type: SelectMotionType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择训练动作"
        if type == .newPlan || type == .edit {
            navigationItem.rightBarButtonItem = btnCommit
        }
        motionView.delegate = self
        tableview.dzy_registerCellNib(PlanSelectMotionCell.self)
        
        listAddHeader()
        listApi(1)
    }
    
    @objc func btnClick() {
        switch type {
        case .edit:
            //编辑状态
            delegate?.returnMotions(sMotionArr)
            dzy_pop()
        case .newPlan:
            let target: [String : Any] = [
                "groupNum" : 1,
                "freNum" : 1,
                "weight" : 1.0
            ]
            let vc = TrainPlanPlayVC(.new)
            vc.dataArr = sMotionArr.map({
                [
                    "motion" : $0,
                    "target" : target
                ]
            })
            vc.dataDic = dataDic // plan 的名字之类的
            dzy_push(vc)
        case .one:
            break
        }
    }

    //从上一个页面带数据过来 默认初始值
    func setData(_ listData: [[String:Any]]) {
        sMotionArr = listData
            .compactMap({$0.dicValue("motion")})
    }
    
    @IBAction func searchAction(_ sender: UIButton) {
        let vc = SearchMotionVC()
        vc.hbd_barHidden = true
        vc.delegate = self
        let nav = HBDNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func addressBookAction() {
        let addressView = AddressBookView.instanceFromNib()
        addressView.frame = self.view.bounds
        navigationController?.view.addSubview(addressView)
    }
    
    func selectMotionAction(_ motion: [String:Any]) {
        guard let code = motion.stringValue("code") else {
            return
        }
        if let index = sMotionArr.firstIndex(where: {$0.stringValue("code") == code})
        {
            sMotionArr.remove(at: index)
        }else {
            sMotionArr.append(motion)
        }
        tableview.reloadData()
    }
    
    func trainOne(_ motion: [String : Any]) {
        var motion = motion
        let type = TPPlayViewType.checkType(motion)
        let target = type.defaultValue()
        // 这里是单个动作的自主训练
        let vc = TrainPlanPlayVC(.playSelf)
        motion["target"] = [target]
        vc.dataArr = [motion]
        dzy_push(vc)
    }
    
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.dic = ["motionPlanCode": currentCode]
        request.page = [page, 50]
        request.isUser = true
        request.url = BaseURL.MotionList
        request.start { (data, error) in
            self.pageOperation(data: data, error: error, isReload: false)
            self.tableview.reloadData(
                with: .simple(
                    duration: 0.75,
                    direction: .rotation3D(type: .ironMan),
                    constantDelay: 0
                )
            )
        }
    }
    
//    MAKR: - 懒加载
    private lazy var btnCommit: UIBarButtonItem = {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 56, height: 24)
        btn.setTitle(type == .edit ? "完成" : "下一步", for: .normal)
        btn.titleLabel?.font = ToolClass.CustomFont(13)
        btn.setTitleColor(YellowMainColor, for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        btn.enableInterval = true
        return UIBarButtonItem(customView: btn)
    }()
}

extension PlanSelectMotionVC: UITableViewDelegate,UITableViewDataSource,MotionSelectDelegate,SearchMotionVCDelegate {
    
    //MARK: ------------MotionSelectDelegate
    func selectMotion(_ code: String) {
        if currentCode == code {return}
        currentCode = code
        listApi(1)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(PlanSelectMotionCell.self)!
        let dic = dataArr[indexPath.row]
        cell.setData(dic)
        let isSelected = sMotionArr
            .contains(where: {$0.stringValue("code") == dic.stringValue("code")})
        cell.selectStatusBtn.isSelected = isSelected
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = dataArr[indexPath.row]
        switch type {
        case .one:
            trainOne(dic)
        default:
            selectMotionAction(dic)
        }
    }
    
    func selectMotion(_ motion: [String : Any]) {
        self.selectMotionAction(motion)
    }
}

