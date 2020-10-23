//
//  TrainPlanPlayVC.swift
//  PPBody
//
//  Created by edz on 2020/1/8.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class TrainPlanPlayVC: BaseVC {
    
    // ***** --- 滚动效果需要的属性 ---
    private var startY: CGFloat = 0
    
    private let x: CGFloat = 200
    
    private var topFrame: CGRect = .zero
    
    private var bottomFrame: CGRect = .zero
    // ***** --- 滚动效果需要的属性 ---
    
    // ***** --- 滚动效果相关的视图 ---
    /// 整体滚动的背景视图
    @IBOutlet weak var sBgView: UIView!
    /// 顶部提示可滚动的视图
    @IBOutlet weak var sTopView: UIView!
    /// 顶部的显示视图中的线
    @IBOutlet weak var sTopLineView: UIView!
    /// 标识符号
    @IBOutlet weak var sTopMarkView: UIView!
    /// 内容滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    /// 内容视图
    @IBOutlet weak var stackView: UIStackView!
    // ***** --- 滚动效果相关的视图 ---
    
    private let type: TrainPlanShowType
    // 锻炼时间
    private var playTime: Int = 0
    
    private var timer: Timer?
    /// 最上面显示时间，完成按钮的视图
    @IBOutlet weak var topView: UIView!
    /// 输入的背景视图
    @IBOutlet weak var inputBgView: UIView!
    /// 完成、保存按钮
    @IBOutlet weak var sureBtn: UIButton!
    /// 训练中状态，完成按钮的百分比
    @IBOutlet weak var sureBtnCoverView: UIView!
    @IBOutlet weak var sureBtnCoverWidthLC: NSLayoutConstraint!
    /// 总计时
    @IBOutlet weak var timeLB: UILabel!
    /// 返回按钮
    @IBOutlet weak var backBtn: UIButton!
    /// 顶部title
    @IBOutlet weak var titleLB: UILabel!
    /// 计划名称
    @IBOutlet weak var planNameTF: UITextField!
    /// 16 32
    @IBOutlet weak var pnameLeftLC: NSLayoutConstraint!
    /// 编辑计划的 icon
    @IBOutlet weak var planEditIV: UIImageView!
    /// 计划备注
    @IBOutlet weak var planDetailTX: UITextView!
    
    private var tfs: [TPTextField] = []
    /// 待删除的数据
    private var removeData: [[String : Any]] = []
    
    init(_ type: TrainPlanShowType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        updateTFs()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputBgView.isHidden = false
    }
    
//    MARK: - 返回
    @IBAction func backAction(_ sender: Any) {
        dzy_pop()
    }
    
    //    MARK: - 添加动作
    private func addMotion() {
        let vc = PlanSelectMotionVC(.edit)
        vc.delegate = self
        dzy_push(vc)
    }
    
//    MARK: - 操作完成
    private func doSuccess() {
        switch type {
        case .new:
            NotificationCenter.default.post(name: Config.Notify_UserAddMotionPlan, object: nil)
            dzy_customPopOrRootPop(TrainPlanEditListVC.self)
        case .play, .playSelf:
            NotificationCenter.default.post(name: Config.Notify_AddTrainingData, object: nil)
            dzy_pop()
        case .planEdit:
            NotificationCenter.default.post(name: Config.Notify_EditMotionPlanData, object: nil)
            removeData.removeAll()
            dzy_pop()
        case .hisEdit:
            NotificationCenter.default.post(name: Config.Notify_EditTrainingData, object: nil)
            removeData.removeAll()
            ToolClass.showToast("编辑成功", .Success)
            dzy_delayPop(1)
        }
    }
    
//    MARK: - pan手势
    @objc private func bgViewPanAction(_ pan: UIPanGestureRecognizer) {
        let height = sBgView.dzy_h
        let width = sBgView.dzy_w
        switch (pan.state) {
        case .began:
            startY = sBgView.dzy_y
            sBgView.isUserInteractionEnabled = false
        case .changed:
            // 如果 scrollView 的dzy_ofy != 0，优先滑到 0 再进行别的
            if scrollView.dzy_ofy != 0 {
                return
            }
            let now = pan.translation(in: pan.view)
            // 不能在初始状态向上滑
            if startY == topFrame.minY,
                now.y <= 0
            {
                return
            }
            let nowy = abs(now.y)
            // 求变量，如果大于临界值，动作幅度变小
            var cy = nowy <= x ? nowy : ((nowy - x) * 0.1 + x)
            if now.y < 0 {
                cy = -cy
            }
            let nowFrame = CGRect(x: 0, y: startY + cy, width: width, height: height)
            UIView.animate(withDuration: 0.1) {
                self.sBgView.frame = nowFrame
            }
            
        case .ended, .failed:
            sBgView.isUserInteractionEnabled = true
            func bottomAnimate() {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                    self.sBgView.frame = self.bottomFrame
                }) { (_) in
                    self.scrollView.isScrollEnabled = false
                }
            }
            func topAnimate() {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                    self.sBgView.frame = self.topFrame
                }) { (_) in
                    self.scrollView.isScrollEnabled = true
                }
            }
            if x / 2.0 > abs(sBgView.dzy_y - startY) {
                if startY == topFrame.origin.y {
                    topAnimate()
                }else {
                    bottomAnimate()
                }
            }else {
                if startY == topFrame.origin.y {
                    bottomAnimate()
                }else {
                    topAnimate()
                }
            }
        default:
            break
        }
    }
    
//    MARK: - baseUI
    private func initUI() {
        sureBtn.titleLabel?.font = dzy_FontBlod(15)
        timeLB.font = dzy_FontNumber(30)
        titleLB.font = dzy_Font(17)
        initScrollView()
        switch type {
        case .play(let pid):
            playUI()
            planDetailApi(pid)
        case .playSelf:
            planNameTF.text = "自主训练"
            playUI()
            updateUI()
        case .planEdit(let pid):
            editUI()
            planDetailApi(pid)
        case .new:
            newUpdatePlanMsg()
            editUI()
            updateUI()
        case .hisEdit(let detail):
            hisEditUI(detail)
            updateUI()
        }
    }
    
    /// 自主训练 和 计划训练基础UI
    private func playUI() {
        initTimer()
        sureBtnCoverView.isHidden = false
        sureBtn.setTitle("完成", for: .normal)
        timeLB.isHidden = false
        backBtn.isHidden = true
        titleLB.isHidden = true
    }
    
    /// 编辑 和 新增 基础 UI
    private func editUI() {
        sureBtn.setTitle("保存", for: .normal)
        timeLB.isHidden = true
        backBtn.isHidden = false
        titleLB.isHidden = false
        pnameLeftLC.constant = 32
        planEditIV.isHidden = false
    }
    
    /// 编辑训练记录的 UI
    private func hisEditUI(_ detail: [String : Any]) {
        sureBtn.setTitle("保存", for: .normal)
        timeLB.isHidden = true
        backBtn.isHidden = false
        titleLB.isHidden = false
        titleLB.text = "编辑训练记录"
        dataArr = detail.arrValue("list") ?? []
        planNameTF.text = detail.stringValue("name")
    }
    
    // 新增时的 计划信息更新
    private func newUpdatePlanMsg() {
        planNameTF.isUserInteractionEnabled = true
        planDetailTX.isUserInteractionEnabled = true
        planNameTF.text = dataDic.stringValue("name")
        planDetailTX.text = dataDic.stringValue("content")
    }
    
    // 计划训练时 计划信息更新
    private func playUpdatePlanMsg(_ data: [String : Any]) {
        planNameTF.isUserInteractionEnabled = false
        planDetailTX.isUserInteractionEnabled = false
        planNameTF.text = data.stringValue("name")
        planDetailTX.text = data.stringValue("content")
    }
    
    // 编辑计划时 计划信息更新
    private func editUpdatePlanMsg(_ data: [String : Any]) {
        planNameTF.isUserInteractionEnabled = true
        planDetailTX.isUserInteractionEnabled = true
        planNameTF.text = data.stringValue("name")
        planDetailTX.text = data.stringValue("content")
    }
    
    /// 滚动相关的视图更新
    private func initScrollView() {
        // 这里必须手写，不然和 Frame 动画起冲突
        sBgView.frame = CGRect(x: 0, y: NaviH + 50, width: ScreenWidth, height: ScreenHeight - NaviH - TabRH - 50)
        switch type {
        case .playSelf, .hisEdit:
            scrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: sBgView.frame.height)
            
            stackView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
            }
        default:
            sTopView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 40)
            scrollView.frame = CGRect(x: 0, y: 40, width: ScreenWidth, height: sBgView.frame.height - 40)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(bgViewPanAction(_:)))
            pan.delegate = self
            sBgView.addGestureRecognizer(pan)
            
            stackView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
            }
            sTopLineView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalTo(0)
                make.height.equalTo(0.5)
            }
            sTopMarkView.snp.makeConstraints { (make) in
                make.width.equalTo(36)
                make.height.equalTo(4)
                make.top.equalTo(9)
                make.centerX.equalToSuperview()
            }
            
            topFrame = sBgView.frame
            bottomFrame = CGRect(x: topFrame.origin.x,
                                 y: topFrame.origin.y + x,
                                 width: topFrame.width,
                                 height: topFrame.height)
        }
    }
    
    private func initTimer() {
        timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.playTime += 1
            let x = self?.playTime ?? 0
            let min = x / 60
            let second = x % 60
            self?.timeLB.text = String(format: "%02ld:%02ld", min, second)
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func updateUI() {
        dataArr.enumerated().forEach { (index, data) in
            let view = TPPlayView.initFromNib()
            switch type {
            case .new:
                view.showInitUI(data)
            case .play, .playSelf, .planEdit:
                view.playOrEditInitUI(data, type: type)
            case .hisEdit:
                view.hisUpdateUI(data, type: type)
            }
            view.tag = index
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
        if case .hisEdit = type {
            
        }else {
            stackView.addArrangedSubview(addView)
        }
    }
    
//    MARK: - 记录所有的 UITextField
    private func updateTFs() {
        tfs.removeAll()
        // 第二层
        let sblock = { (sview: UIView) in
            guard let sview = sview as? TPPlaySourceView else {
                return
            }
            self.tfs.append(sview.numOrTimeTF)
            self.tfs.append(sview.weightOrDistanceTF)
        }
        // 第一层
        let fblock = { (mview: UIView) in
            guard let mview = mview as? TPPlayView else {return}
            mview.stackView.arrangedSubviews.forEach(sblock)
        }
        stackView.arrangedSubviews.forEach(fblock)
    }
    
//    MARK: - 完成按钮
    @IBAction func sureAction(_ sender: Any) {
        var arrDic: [[String : Any]] = []
        stackView.arrangedSubviews.enumerated().forEach { (index, view) in
            guard let view = view as? TPPlayView,
                index < dataArr.count else {return}
            switch type {
            case .new:
                guard let target = view.values(),
                    let motionID = dataArr[index]
                    .dicValue("motion")?.intValue("id"),
                    target.count > 0
                else {return}
                let dic: [String : Any] = [
                    "motionId" : motionID,
                    "target" : target
                ]
                arrDic.append(dic)
            case .planEdit:
                guard let target = view.values(.edit),
                    let motionID = dataArr[index].intValue("id"),
                    target.count > 0
                else {return}
                let dic: [String : Any] = [
                    "motionId" : motionID,
                    "target" : target
                ]
                arrDic.append(dic)
            case .play, .playSelf:
                guard let list = view.values(.selected),
                    list.count > 0,
                    let motionID = dataArr[index].intValue("id")
                else {return}
                let dic: [String : Any] = [
                    "motionId" : motionID,
                    "list" : list
                ]
                arrDic.append(dic)
            case .hisEdit:
                guard let change = view.values(.edit),
                    let umgId = dataArr[index].intValue("userMotionGroupId"),
                    change.count > 0
                else {return}
                let dic: [String : Any] = [
                    "userMotionGroupId" : umgId,
                    "change" : change
                ]
                arrDic.append(dic)
            }
        }
        guard !arrDic.isEmpty else {
            // 这里如果是创建计划 new 类型，在 view 的层次会给警告，什么都不用做
            switch type {
            case .play, .playSelf:
                dzy_pop()
            default:
                break
            }
            return
        }
        switch type {
        case .new:
            /**
                新增和编辑，如果小于代表有某一行输入错误
                -1 是因为最下面有个 addView
            */
            if arrDic.count < stackView.arrangedSubviews.count - 1 {
                break
            }
            let rdic: [String : String] = [
                "name" : dataDic.stringValue("name") ?? "",
                "content" : dataDic.stringValue("content") ?? "",
                "plan" : ToolClass.toJSONString(dict: arrDic)
            ]
            savePlanApi(rdic)
        case .planEdit(let pid):
            /**
                新增和编辑，如果小于代表有某一行输入错误
                -1 是因为最下面有个 addView
            */
            if arrDic.count < stackView.arrangedSubviews.count - 1 {
                break
            }
            arrDic.append(contentsOf: removeData)
            let rdic: [String : String] = [
                "name" : planNameTF.text ?? "",
                "content" : planDetailTX.text ?? "",
                "plan" : ToolClass.toJSONString(dict: arrDic),
                "motionPlanId" : "\(pid)"
            ]
            savePlanApi(rdic)
        case .hisEdit(let detail):
            /**
                新增和编辑，如果小于代表有某一行输入错误
                -1 是因为最下面有个 addView
            */
            if arrDic.count < stackView.arrangedSubviews.count {
                break
            }
            guard let umpId = detail.intValue("id") else {
                return
            }
            arrDic.append(contentsOf: removeData)
            let rdic: [String : String] = [
                "changes" : ToolClass
                    .toJSONString(dict: arrDic),
                "userMotionPlanId" : "\(umpId)"
            ]
            trainEditApi(rdic)
            print(rdic)
        case .play(let pid):
            let rdic: [String : String] = [
                "motionPlanId" : "\(pid)",
                "trainingData" : ToolClass.toJSONString(dict: arrDic),
                "totalTime" : "\(playTime)"
            ]
            addPlanDataApi(rdic)
        case .playSelf:
            let dic = [
                "totalTime" : "\(playTime)",
                "trainingData" : ToolClass.toJSONString(dict: arrDic)
            ]
            addDataApi(dic)
        }
    }
    
    //    MARK: - api
    private func savePlanApi(_ dic: [String: String]) {
        let request = BaseRequest()
        request.url = BaseURL.UserEditMotionPlan
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.doSuccess()
            }
        }
    }
    
    private func trainEditApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.TrainEdit
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.doSuccess()
            }
        }
    }
    
    private func addPlanDataApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.AddPlanData
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.doSuccess()
            }
        }
    }
    
    private func addDataApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.dic = dic
        request.isUser = true
        request.url = BaseURL.AddTrainingData
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.doSuccess()
            }
        }
    }
    
    private func planDetailApi(_ pid: Int) {
        let request = BaseRequest()
        request.url = BaseURL.MotionPlanDetail
        request.dic = ["motionPlanId" : "\(pid)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            let dic = data?.dicValue("motionPlanDetail") ?? [:]
            self.dataArr = dic.arrValue("motionList") ?? []
            switch self.type {
            case .play:
                self.playUpdatePlanMsg(dic)
            case .planEdit:
                self.editUpdatePlanMsg(dic)
            default:
                break
            }
            self.updateUI()
        }
    }
    
//    MARK: - 懒加载
    
    /// 底部添加动作
    private lazy var addView: TPPlayBottomView = {
        let view = TPPlayBottomView.initFromNib()
        view.handler = { [weak self] in
            self?.addMotion()
        }
        return view
    }()
    
    /// 设置时间间隔
    private lazy var restView: TPPSetRestView = {
        let view = TPPSetRestView.initFromNib()
        view.frame = CGRect(x: 0, y: 0,
                            width: ScreenWidth - 40, height: 345)
        view.delegate = self
        return view
    }()
    
    /// 计时运动设置时长
    private lazy var timeView: TPPSetTimeView = {
        let view = TPPSetTimeView.initFromNib()
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 250)
        return view
    }()
    
    /// 转圈倒计时
    private lazy var cdView: TPPCountDownView = {
        let view = TPPCountDownView.initFromNib()
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 32.0, height: 345)
        view.initUI()
        return view
    }()
    
    private lazy var centerPopView = DzyPopView(.POP_center_above, viewBlock: restView)
    
    private lazy var bottomPopView = DzyPopView(.POP_bottom, viewBlock: timeView)
}

extension TrainPlanPlayVC: TPPlayViewDelegate {
    
    func playView(_ playView: TPPlayView, didRunEnd sourceView: TPPlaySourceView) {
        // 已经完成的数量
        var end: CGFloat = 0
        // 还未完成的数量
        var no: CGFloat = 0
        stackView.arrangedSubviews.forEach { (wview) in
            guard let wview = wview as? TPPlayView else {return}
            wview.stackView.arrangedSubviews.forEach { (iview) in
                guard let iview = iview as? TPPlaySourceView else {return}
                if iview.selectBtn.isSelected {
                    end += 1
                }else {
                    no += 1
                }
            }
        }
        /// 未完成的百分比
        let x = no / (end + no)
        sureBtnCoverWidthLC.constant = 61 * x
        UIView.animate(withDuration: 0.25) {
            self.topView.setNeedsLayout()
            self.topView.layoutIfNeeded()
        }
    }
    
    func playView(_ playView: TPPlayView, didStartCountDown sourceView: TPPlaySourceView, btn: UIButton) {
        guard cdView.timerHl == nil else {
            btn.isSelected = false
            ToolClass.showToast("您有正在执行动作", .Failure)
            return
        }
        let rest = sourceView.getRestStr()
        // 等于 0 则直接结束
        if rest == 0 {
            sourceView.endTrain(0)
            return
        }
        centerPopView.updateSourceView(cdView)
        centerPopView.show()
        sourceView.startTrain()
        cdView.start(TimeInterval(rest), timerHl: { (cdtime) in
            sourceView.timerLB.text = "\(Int(cdtime))"
        }, finishedHl: { (uValue) in
            sourceView.endTrain(uValue)
        }) { (maxTime) in
            sourceView.timeLB.text = "\(Int(maxTime))s"
        }
    }
    
    func playView(_ playView: TPPlayView,
                  didClickSetTimeBtn sourceView: TPPlaySourceView,
                  btn: UIButton,
                  tf: UITextField?)
    {
        let text = tf?.text ?? "00:00"
        let timeArr = text.components(separatedBy: ":")
        guard timeArr.count == 2 else {return}
        let min = Int(timeArr[0]) ?? 0
        let second = Int(timeArr[1]) ?? 0
        timeView.updateUI(min: min, second: second)
        timeView.currentTF = tf
        bottomPopView.show()
    }
    
    func playView(_ playView: TPPlayView,
                  didSelectNextTF tf: TPTextField,
                  action: TPKeyboardActionType) {
        switch action {
        case .next:
            if let index = tfs.firstIndex(of: tf),
                (index + 1) < tfs.count
            {
                tfs[index + 1].becomeFirstResponder()
            }
        default:
            break
        }
    }
    
    func playView(_ playView: TPPlayView,
                  didSelectRestBtn btn: UIButton) {
        centerPopView.updateSourceView(restView)
        restView.tag = playView.tag
        centerPopView.show()
    }
    
    func didSelectAddGroupAction(with playView: TPPlayView) {
        updateTFs()
    }
    
    func playView(_ playView: TPPlayView,
                  didRemoveWith motion: [String : Any],
                  removeData: [[String : Any]])
    {
        switch type {
        case .planEdit:
            let motionId = motion.intValue("id") ?? 0
            dataArr.removeAll(where: {
                $0.dicValue("motion")?.intValue("id") == motionId
            })
            self.removeData.append([
                "motionId" : motionId,
                "target" : removeData
            ])
        case .hisEdit:
            // 这里的 motion 其实是 组信息，并不算是动作信息
            let umgId = motion.intValue("userMotionGroupId") ?? 0
            dataArr.removeAll(where: {
                $0.intValue("userMotionGroupId") == umgId
            })
            self.removeData.append([
                "userMotionGroupId" : umgId,
                "change" : removeData
            ])
        default:
            break
        }
        
    }
}
 
extension TrainPlanPlayVC: TPPSetRestViewDelegate {
    func restView(_ restView: TPPSetRestView,
                  didSetTime time: Int,
                  isAll: Bool)
    {
        func setTime(_ playView: TPPlayView) {
            playView.stackView.arrangedSubviews.forEach { (view) in
                if let view = view as? TPPlaySourceView {
                    view.timeLB.text = "\(time)s"
                }
            }
        }
        if isAll {
            stackView.arrangedSubviews.forEach { (view) in
                if let view = view as? TPPlayView {
                    setTime(view)
                }
            }
        }else {
            if let view = stackView
                .arrangedSubviews[restView.tag] as? TPPlayView
            {
                setTime(view)
            }
        }
    }
}

extension TrainPlanPlayVC: PlanSelectMotionDelegate {
    
    /// 新建计划时的返回值处理
    private func newHandler(new: [String : Any]) {
        guard let cmid = new.intValue("id") else {return}
        if !self.dataArr.contains(where: { (old) -> Bool in
            old.dicValue("motion")?.intValue("id") == cmid
        }) {
            let target: [String : Any] = [
                "groupNum" : 1,
                "freNum" : 1,
                "weight" : 1.0
            ]
            let dic: [String : Any] = [
                "motion" : new,
                "target" : target
            ]
            self.dataArr.append(dic)
        }
    }
    
    /// 训练的返回值处理
    private func playHandler(new: [String : Any]) {
        guard let cmid = new.intValue("id") else {return}
        if !self.dataArr.contains(where: { (old) -> Bool in
            old.intValue("id") == cmid
        }) {
            let target: [String : Any] = [
                "groupNum" : 1,
                "freNum" : 1,
                "weight" : 1.0
            ]
            var dic = new
            dic["target"] = [target]
            self.dataArr.append(dic)
        }
    }
    
    func returnMotions(_ data: [[String : Any]]) {
        switch type {
        case .new:
            data.forEach(newHandler)
        case .playSelf, .play, .planEdit:
            data.forEach(playHandler)
        case .hisEdit:
            /// 编辑记录不能添加新动作
            break
        }
        
        // new 状态
        let max = dataArr.count
        let min = stackView.arrangedSubviews.count - 1
        guard max > min else {return}
        (min..<max).forEach { (index) in
            let data = dataArr[index]
            let view = TPPlayView.initFromNib()
            switch type {
            case .new:
                view.showInitUI(data)
            case .playSelf, .play, .planEdit:
                view.playOrEditInitUI(data, type: type)
            case .hisEdit(let detail):
                view.hisUpdateUI(detail, type: type)
            }
            view.tag = index
            view.delegate = self
            let x = stackView.arrangedSubviews.count - 1
            stackView.insertArrangedSubview(view, at: x)
        }
    }
}

extension TrainPlanPlayVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == scrollView.panGestureRecognizer
    }
}
