//
//  TrainingVC.swift
//  PPBody
//
//  Created by edz on 2019/12/18.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainingVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    @IBOutlet weak var mTitleLB: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var iconIV: UIImageView!
    /*
    // 是否为学员
    private var isOther = false
     */
    
    deinit {
        deinitObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        loadData()
        getClubsApi()
        
        registObservers([
            Config.Notify_UserEditWeekMotionPlan,
            Config.Notify_AddTrainingData
        ]) { [weak self] (_) in
            self?.loadData()
        }
        
        /*
        registObservers([Config.Notify_ChangeMember]) { [weak self] _ in
            let user = DataManager.memberInfo()
            if user != nil {
                self?.isOther = true
                self?.iconIV.setHeadImageUrl(DataManager.getMemberHead()!)
            }else{
                self?.isOther = false
                self?.iconIV.setHeadImageUrl(DataManager.getHead())
            }
            self?.loadData()
        }
        */
    }
    
    private func initUI() {
        mTitleLB.font = dzy_FontBBlod(27)
        stackView.addArrangedSubview(dataView)
        stackView.addArrangedSubview(planView)
        stackView.addArrangedSubview(bodyView)
        stackView.addArrangedSubview(tagView)
        iconIV.setCoverImageUrl(DataManager.getHead())
        /*
        if DataManager.isCoach() {
            iconIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressBookAction)))
        }
        */
    }
    
    private func updateUI(_ data: [String : Any]) {
        dataView.updateUI(data.dicValue("total") ?? [:],
                          weakt: data["weekTraining"] as? [Int] ?? [])
        planView.initUI(data.arrValue("weekPlan") ?? [])
        bodyView.initUI(data.dicValue("bodyStatus") ?? [:],
                        bodys: data["bodyTraining"] as? [Int] ?? [])
    }
    
    /*
    @objc func addressBookAction() {
        (parent as? PPBodyMainVC)?.addressBookAction()
    }
    */
    
//    MARK: - Api
    private func loadData() {
        let request = BaseRequest()
        request.url = BaseURL.TrainingHome
        request.isUser = true
        /*
        if isOther {
            request.isOther = true
        }else {
            request.isUser = true
        }
        */
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.updateUI(data ?? [:])
        }
    }
    
    //    MARK: - 获取用户俱乐部
    func getClubsApi() {
        let type = DataManager.userInfo()?.intValue("type") ?? 10
        let request = BaseRequest()
        request.url = BaseURL.Clubs
        request.dic = ["type" : "\(type)"]
        request.isUser = true
        request.start { [weak self] (data, error) in
            if let list = data?.arrValue("list"),
                list.count > 0
            {
                let vc = BindGymVC(list)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }

//    MARK: - 懒加载
    private lazy var dataView: TrainDataView = {
        let view = TrainDataView.initFromNib()
        view.delegate = self
        return view
    }()
    
    private lazy var planView: TrainPlanView = {
        let view = TrainPlanView.initFromNib()
        view.delegate = self
        return view
    }()
    
    private lazy var bodyView = TrainBodyView.initFromNib()
    
    private lazy var tagView: TrainTagView = {
        let view = TrainTagView.initFromNib()
        return view
    }()
}

//MARK: - 训练详情、历史轨迹
extension TrainingVC: TrainDataViewDelegate {
    func dateView(_ dataView: TrainDataView,
                  didSelectDetailBtn btn: UIButton) {
        let vc = StatisticsMotionVC()
        dzy_push(vc)
    }
    
    func dateView(_ dataView: TrainDataView,
                  didSelectHistoryBtn btn: UIButton) {
        let vc = TrainHistoryVC()
        dzy_push(vc)
    }
}

//MARK: - 训练计划 开始、编辑
extension TrainingVC: TrainPlanViewDelegate {
    func planView(_ planView: TrainPlanView,
                  didClickPlan plan: [String : Any]) {
        let pid = plan.intValue("id") ?? 0
        let vc = TrainPlanPlayVC(.play(pid: pid))
        dzy_push(vc)
    }
}
