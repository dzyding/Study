//
//  TPPlayView.swift
//  PPBody
//
//  Created by edz on 2020/1/8.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

protocol TPPlayViewDelegate: class {
    /// 点击 next
    func playView(_ playView: TPPlayView,
                  didSelectNextTF tf: TPTextField,
                  action: TPKeyboardActionType)
    /// 一组训练做完
    func playView(_ playView: TPPlayView, didRunEnd sourceView: TPPlaySourceView)
    /// 点击设置间歇时间
    func playView(_ playView: TPPlayView, didSelectRestBtn btn: UIButton)
    /// 点击开始倒计时
    func playView(_ playView: TPPlayView,
                  didStartCountDown sourceView: TPPlaySourceView,
                  btn: UIButton)
    /// 点击设置计时训练的时长
    func playView(_ playView: TPPlayView,
                  didClickSetTimeBtn sourceView: TPPlaySourceView,
                  btn: UIButton,
                  tf: UITextField?)
    /// 移除整个动作
    func playView(_ playView: TPPlayView,
                  didRemoveWith motion: [String : Any],
                  removeData: [[String: Any]])
    /// 添加一组
    func didSelectAddGroupAction(with playView: TPPlayView)
}

class TPPlayView: UIView, InitFromNibEnable {
    
    private var actionType: TrainPlanShowType = .new
    
    private var viewType: TPPlayViewType = .normal
    
    @IBOutlet weak var mZuLB: UILabel!
    @IBOutlet weak var mCiLB: UILabel!
    @IBOutlet weak var mWeightLB: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    weak var delegate: TPPlayViewDelegate?
    /// 35 * n
    @IBOutlet weak var heightLC: NSLayoutConstraint!
    
    @IBOutlet weak var normalTitleSV: UIStackView!
    
    @IBOutlet weak var cardioTitleSV: UIStackView!
    
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var detailLB: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private var row: Int = 0
    /// 主要是训练动作相关的信息
    private var motion: [String : Any] = [:]
    /// 删除的数据
    private var removeData: [[String : Any]] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLB.font = dzy_FontBlod(15)
        detailLB.font = dzy_FontBlod(12)
        [mZuLB, mCiLB, mWeightLB].forEach { (label) in
            label?.font = dzy_FontBlod(12)
        }
        addBtn.titleLabel?.font = dzy_FontBlod(13)
    }
    
    func values(_ type: TPPValueType = .normal) -> [[String : Any]]? {
        var arr: [[String : Any]] = []
        var count = 0
        stackView.arrangedSubviews.enumerated().forEach { (index, view) in
            // 第一个是头部标题，所以要略过
            guard index > 0 else {return}
            guard let view = view as? TPPlaySourceView,
                let value = view.values(type)
            else {
                count += 1
                return
            }
            arr.append(value)
        }
        arr.append(contentsOf: removeData)
        // 在新增或者编辑时，如果出现 count > 0，则表示输入有误
        if type != .selected,
            count > 0
        {
            return nil
        }else {
            return arr
        }
    }
    
    func showInitUI(_ data: [String : Any]) {
        actionType = .new
        let target = data.dicValue("target") ?? [:]
        let motion = data.dicValue("motion")
        row = target.intValue("groupNum") ?? 0
        viewType = TPPlayViewType.checkType(motion)
        updateUI()
        self.motion = motion ?? [:]
        guard row > 0 else {return}
        heightLC.constant = CGFloat(row + 1) * 35.0
        (1...row).forEach { (index) in
            let cell = TPPlaySourceView.initFromNib()
            cell.showOrEditUpdateUI(target,
                                    index: index,
                                    type: viewType)
            cell.delegate = self
            stackView.addArrangedSubview(cell)
        }
        
        nameLB.text = motion?.stringValue("name")
        detailLB.text = motion?.stringValue("trainingCore")
        iconIV.setCoverImageUrl(motion?.stringValue("cover") ?? "")
    }
    
    func playOrEditInitUI(_ data: [String : Any], type: TrainPlanShowType) {
        actionType = type
        viewType = TPPlayViewType.checkType(data)
        updateUI()
        let datas = data.arrValue("target") ?? []
        row = datas.count
        self.motion = data
        guard row > 0 else {return}
        heightLC.constant = CGFloat(row + 1) * 35.0
        (1...row).forEach { (index) in
            let cell = TPPlaySourceView.initFromNib()
            switch type {
            case .playSelf, .play:
                cell.playUpdateUI(datas[index - 1],
                                  index: index,
                                  type: viewType)
            case .planEdit:
                cell.showOrEditUpdateUI(datas[index - 1],
                                        index: index,
                                        type: viewType)
            case .new, .hisEdit:
                break
            }
            
            cell.delegate = self
            stackView.addArrangedSubview(cell)
        }
        
        nameLB.text = data.stringValue("name")
        detailLB.text = data.stringValue("position")
        iconIV.setCoverImageUrl(data.stringValue("cover") ?? "")
    }
    
    func hisUpdateUI(_ data: [String : Any], type: TrainPlanShowType) {
        actionType = type
        viewType = TPPlayViewType.hisCheckType(data)
        updateUI()
        let datas = data.arrValue("list") ?? []
        row = datas.count
        self.motion = data
        guard row > 0 else {return}
        heightLC.constant = CGFloat(row + 1) * 35.0
        (1...row).forEach { (index) in
            let cell = TPPlaySourceView.initFromNib()
            cell.hisUpdateUI(datas[index - 1],
                             fatherData: data,
                             index: index,
                             type: viewType)
            cell.delegate = self
            stackView.addArrangedSubview(cell)
        }
        
        nameLB.text = data.stringValue("name")
        detailLB.text = nil
        iconIV.setCoverImageUrl(data.stringValue("cover"))
    }
    
//    MARK: - 更新 UI
    private func updateUI() {
        switch viewType {
        case .cardio:
            normalTitleSV.isHidden = true
            cardioTitleSV.isHidden = false
            (cardioTitleSV.arrangedSubviews.last as? UILabel).flatMap({
                $0.text = " "
            })
        case .run:
            normalTitleSV.isHidden = true
            cardioTitleSV.isHidden = false
        default:
            break
        }
    }
    
//    MARK: - 设置间隔时间
    @IBAction func timeAction(_ sender: UIButton) {
        delegate?.playView(self, didSelectRestBtn: sender)
    }
    
//    MARK: - 加一组
    @IBAction func addAction() {
        row += 1
        updateHeightLC()
        let cell = TPPlaySourceView.initFromNib()
        var new: [String : Any] = [:]
        if row == 1 {
            new = viewType.defaultValue()
        }else {
            new = (stackView.arrangedSubviews[row - 1] as? TPPlaySourceView)?
                .valuesOrDefault() ?? [:]
        }
        switch actionType {
        case .hisEdit:
            cell.hisUpdateUI(new, fatherData: motion, index: row, type: viewType, isNew: true)
        case .new, .planEdit:
            cell.showOrEditUpdateUI(new, index: row, type: viewType)
        case .play, .playSelf:
            cell.playUpdateUI(new, index: row, type: viewType)
        }
        
        cell.delegate = self
        stackView.addArrangedSubview(cell)
        
        delegate?.didSelectAddGroupAction(with: self)
    }
    
    private func updateHeightLC() {
        heightLC.constant = CGFloat(row + 1) * 35.0
    }
}

extension TPPlayView: TPPlaySourceViewDelegate {
    
    func didRunEnd(_ sView: TPPlaySourceView) {
        delegate?.playView(self, didRunEnd: sView)
    }
    
    func sView(_ sView: TPPlaySourceView, didRemove btn: UIButton, targetId: Int?, umId: Int?) {
        if stackView.arrangedSubviews.count <= 2 {
            let alert = dzy_normalAlert("提示", msg: "目前该动作只有这一组，进行删除操作将直接移除该动作，是否继续", sureClick: { [weak self] (_) in
                guard let sSelf = self else {return}
                sSelf.updateRemoveData(targetId, umId: umId)
                sSelf.delegate?
                    .playView(sSelf,
                              didRemoveWith: sSelf.motion,
                              removeData: sSelf.removeData)
                sSelf.removeFromSuperview()
            }, cancelClick: nil)
            parentVC?.present(alert, animated: true, completion: nil)
        }else {
            sView.removeFromSuperview()
            updateRemoveData(targetId, umId: umId)
            row -= 1
            updateHeightLC()
        }
    }
    
    private func updateRemoveData(_ targetId: Int?,
                                  umId: Int?) {
        targetId.flatMap({
            removeData.append([
                "targetId" : $0,
                "action" : "delete"
            ])
        })
        umId.flatMap({
            removeData.append([
                "userMotionId" : $0,
                "action" : "delete"
            ])
        })
    }
    
    func sView(_ sView: TPPlaySourceView, didClickStart btn: UIButton) {
        delegate?.playView(self, didStartCountDown: sView, btn: btn)
    }
    
    func sView(_ sView: TPPlaySourceView,
               didSelectNext tf: TPTextField,
               action: TPKeyboardActionType
    ) {
        switch action {
        case .next:
            delegate?.playView(self,
                               didSelectNextTF: tf,
                               action: action)
        case .addGroup:
            addAction()
            delegate?.didSelectAddGroupAction(with: self)
        default:
            break
        }
    }
    
    func sView(_ sView: TPPlaySourceView,
               didClickSetTime btn: UIButton,
               tf: UITextField?
    ) {
        delegate?.playView(self, didClickSetTimeBtn: sView, btn: btn, tf: tf)
    }
}
