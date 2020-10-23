//
//  AddHouseInfoHeaderView.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HouseInfoInput where Self: UIView {
    func setText(_ text: String?)
    func getText() -> String
    func closeAcion()
}

protocol AddHouseInfoHeaderViewDelegate: class {
    func infoView(_ infoView: AddHouseInfoHeaderView, didSelectInput input: HouseInfoInput)
    func infoView(_ infoView: AddHouseInfoHeaderView, didEndEditing textField: UITextField)
    func infoView(_ infoView: AddHouseInfoHeaderView, didClickMapBtn btn: UIButton)
}

enum HouseInfoInputType: Int {
    /// 行政区
    case region = 1
    /// 片区
    case district
    /// 小区
    case community
    /// 门牌号
    case houseId
    /// 电梯
    case lift
    /// 装修
    case decorate
    /// 朝向
    case toward
    /// 建成时间
    case buildtime
    /// 产权
    case property
    /// 用途
    case use
}

class AddHouseInfoHeaderView: UICollectionReusableView {
    
    weak var delegate: AddHouseInfoHeaderViewDelegate?
    /// 行政区
    @IBOutlet weak var regionLBInput: LBInputView!
    /// 片区
    @IBOutlet weak var districtLBInput: LBInputView!
    /// 小区
    @IBOutlet weak var communityTFInput: TFInputView!
    /// 门牌号
    @IBOutlet weak var houseIDView: AddHouseStyleInputView!
    /// 户型
    @IBOutlet weak var layoutView: AddHouseStyleInputView!
    /// 面积
    @IBOutlet weak var areaTF: UITextField!
    /// 第N层
    @IBOutlet weak var currentFloorTF: UITextField!
    /// 共N层
    @IBOutlet weak var totalFloorTF: UITextField!
    /// 电梯
    @IBOutlet weak var liftLBInput: LBInputView!
    /// 装修
    @IBOutlet weak var decorateLBInput: LBInputView!
    ///朝向
    @IBOutlet weak var towardLBInput: LBInputView!
    /// 建成时间
    @IBOutlet weak var buildtimeLBInput: LBInputView!
    /// 产权
    @IBOutlet weak var propertyLBInput: LBInputView!
    /// 用途
    @IBOutlet weak var useLBInput: LBInputView!
    /// 地图按钮
    @IBOutlet weak var mapBtn: UIButton!
    /// 价格视图
    @IBOutlet weak var priceView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subviews.forEach { (view) in
            if let lbinput = view as? LBInputView {
                lbinput.delegate = self
            }else if let tfinput = view as? TFInputView {
                tfinput.delegate = self
            }
        }
        layoutView.updateUI("()室()厅()卫", ph: nil)
    }
    
    func updateHouseId(_ style: String?, ph: String?) {
        houseIDView.updateUI(style, ph: ph)
    }
    
    @IBAction func mapAction(_ sender: UIButton) {
        delegate?.infoView(self, didClickMapBtn: sender)
    }
}

extension AddHouseInfoHeaderView: LBInputViewDelegate, TFInputViewDelegate {
    
    func lbInputView(_ inputView: LBInputView, didSelctedBtn btn: UIButton) {
        delegate?.infoView(self, didSelectInput: inputView)
    }
    
    func tfInputView(_ inputView: TFInputView, didSelectBtn btn: UIButton) {
        delegate?.infoView(self, didSelectInput: inputView)
    }
    
    func tfInputView(_ inputView: TFInputView, didEndEditing textField: UITextField) {
        delegate?.infoView(self, didEndEditing: textField)
    }
}
