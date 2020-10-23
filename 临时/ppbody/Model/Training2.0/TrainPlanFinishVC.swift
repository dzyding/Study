//
//  TrainPlanFinishVC.swift
//  PPBody
//
//  Created by edz on 2020/1/7.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanFinishVC: BaseVC, ObserverVCProtocol {
    
    var observers: [[Any?]] = []
    
    private let planId: Int
    
    private var detail: [String : Any] = [:]

    @IBOutlet weak var fTitleLB: UILabel!
    @IBOutlet weak var sTitleLB: UILabel!
    
    @IBOutlet weak var detailLB: UILabel!
    @IBOutlet weak var mGroupLB: UILabel!
    @IBOutlet weak var groupNumLB: UILabel!
    @IBOutlet weak var mMinLB: UILabel!
    @IBOutlet weak var totalMinLB: UILabel!
    @IBOutlet weak var mWeightLB: UILabel!
    @IBOutlet weak var weightNumLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    deinit {
        deinitObservers()
    }
    
    init(_ planId: Int) {
        self.planId = planId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        loadData()
        
        registObservers([Config.Notify_EditTrainingData]) { [weak self] (_) in
            self?.loadData()
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
    
    @IBAction func backAction(_ sender: Any) {
        dzy_pop()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
    }
    
    @IBAction func editAction(_ sender: Any) {
        let vc = TrainPlanPlayVC(.hisEdit(detail: detail))
        dzy_push(vc)
    }
    
    private func updateUI(_ dic: [String : Any]) {
        detail = dic
        fTitleLB.text = "第\(dic.intValue("num") ?? 1)次"
        sTitleLB.text = dic.stringValue("name")
        detailLB.text = "\(dic.stringValue("createTime") ?? "")" + "  完成训练"
        groupNumLB.text = "\(dic.intValue("groupNum") ?? 0)"
        weightNumLB.text = (dic.doubleValue("totalWeight") ?? 0).decimalStr
        totalMinLB.text = (dic.doubleValue("totalTime") ?? 0).decimalStr
        
        while stackView.arrangedSubviews.count > 0 {
            stackView.arrangedSubviews
                .last?.removeFromSuperview()
        }
        let list = dic.arrValue("list") ?? []
        list.enumerated().forEach { (index, dic) in
            let cell = TrainFinishListCell.initFromNib()
            cell.initUI(dic, index: index)
            stackView.addArrangedSubview(cell)
        }
    }
    
    private func initUI() {
        fTitleLB.font = dzy_FontBlod(30)
        sTitleLB.font = dzy_FontBlod(30)
        detailLB.font = dzy_FontBlod(11)
        [mGroupLB, mWeightLB, mMinLB].forEach { (label) in
            label?.font = dzy_FontBlod(12)
        }
        [groupNumLB, weightNumLB, totalMinLB].forEach { (label) in
            label?.font = dzy_FontBBlod(18)
        }
    }

//    MARK: - loadData
    private func loadData() {
        let request = BaseRequest()
        request.url = BaseURL.TrainDetail
        request.dic = ["userMotionPlanId" : "\(planId)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let detail = data?.dicValue("trainingDetail") ?? [:]
            self.updateUI(detail)
        }
    }
}
