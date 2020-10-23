//
//  CoachGymVC.swift
//  PPBody
//
//  Created by edz on 2019/4/28.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachGymVC: BaseVC {
    
    @IBOutlet weak var stackView: UIStackView!
    
    weak var personVC: PersonalVC?
    
    private let clubid: Int
    
    init(_ clubid: Int) {
        self.clubid = clubid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.isHidden = true
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(sellView)
        stackView.addArrangedSubview(classNumView)
        stackView.addArrangedSubview(classView)
        
        clubInfoApi()
        reserveListApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //    MARK: - 返回
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    //    MARK: - 更新视图
    private func updateUI(_ data: [String : Any]) {
        let info = data.dicValue("info") ?? [:]
        let club = data.dicValue("club") ?? [:]
        let classNum = info.intValue("classes") ?? 0
        headerView.ptSetUI(club, num: info.intValue("members") ?? 0) { [weak self] in
            let vc = CoachMemberListVC()
            self?.dzy_push(vc)
        }
        sellView.updateUI(info)
        classNumView.updateUI(classNum)
        
        stackView.isHidden = false
    }
    
    private func updateClasses(_ data: [String : Any]) {
        let list = data.arrValue("list") ?? []
        classView.updateUI(list)
    }

    //    MARK: - 解除绑定
    @IBAction func cancelBindAction(_ sender: UIButton) {
        let alert = dzy_normalAlert("提示",
                                    msg: "你确定要进行解绑操作吗？解绑以后无法再次绑定，如需恢复请联系 皮皮小助手",
                                    sureClick: { [weak self] (_) in
            self?.cancelBindNextAction()
            }, cancelClick: nil)
        DispatchQueue.main.async {
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func cancelBindNextAction() {
        let user = DataManager.userInfo()
        guard let type = user?.intValue("type") else {return}
        let dic = [
            "type"      : "\(type)",
            "clubId"    : "\(clubid)",
            "action"    : "\(20)",
            "smId"      : "\(DataManager.smid())",
            "head"      : user?.stringValue("head") ?? "",
            "nickname"  : user?.stringValue("nickname") ?? ""
        ]
        cancelBindApi(dic)
    }
    
    //    MARK: - 健身房信息
    func clubInfoApi() {
        let request = BaseRequest()
        request.url = BaseURL.CoachClub
        request.isSaasPt = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data {
                self.updateUI(data)
            }
        }
    }
    
    //    MARK: - 解除绑定Api
    func cancelBindApi(_ dic :[String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.ClubAction
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.personVC?.getMyclubApi()
                self.dzy_popRoot()
            }
        }
    }
    
    //    MARK: - 今日预约详情
    func reserveListApi() {
        let time = dzy_date8().description.components(separatedBy: " ").first ?? ""
        let request = BaseRequest()
        request.url = BaseURL.ReserveList_Pt
        request.dic = ["reserveTime" : time]
        request.isSaasPt = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if let data = data {
                self.updateClasses(data)
            }
        }
    }
    
    //    MARK: - 懒加载
    private lazy var headerView = MyGymHeaderView.initFromNib(MyGymHeaderView.self)
    
    private lazy var sellView: CoachGymSellView = {
        let sView = CoachGymSellView.initFromNib(CoachGymSellView.self)
        sView.delegate = self
        return sView
    }()
    
    private lazy var classNumView: CoachGymClassNumView = {
        let numView = CoachGymClassNumView.initFromNib(CoachGymClassNumView.self)
        numView.delegate = self
        return numView
    }()
    
    private lazy var classView: CoachGymClassView = {
        let cView = CoachGymClassView.initFromNib(CoachGymClassView.self)
        cView.delegate = self
        return cView
    }()
}

//MARK: - CoachGymSellViewDelegate, CoachGymClassNumViewDelegate, CoachGymClassViewDelegate
extension CoachGymVC: CoachGymSellViewDelegate, CoachGymClassNumViewDelegate, CoachGymClassViewDelegate {
    // 本月销售详情
    func sellView(_ sellView: CoachGymSellView, didSelectMoreBtn btn: UIButton) {
        let vc = CoachSellListVC()
        dzy_push(vc)
    }
    // 本月上课数详情
    func classNumView(_ classNumView: CoachGymClassNumView, didSelectedMoreBtn btn: UIButton) {
        let vc = CoachClassListVC()
        dzy_push(vc)
    }
    // 预约情况详情
    func classView(_ classView: CoachGymClassView, didSelectMoreBtn btn: UIButton) {
        let vc = CoachReduceFatherVC()
        dzy_push(vc)
    }
}
