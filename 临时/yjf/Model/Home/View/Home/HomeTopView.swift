//
//  HomeTopView.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HomeTopViewDelegate {
    /// 切换城市
    func topView(_ topView: HomeTopView, didSelectCityBtn btn: UIButton)
    /// 买/卖
    func topView(_ topView: HomeTopView, didChangeType typeInt: Int)
    /// 扫一扫
    func topView(_ topView: HomeTopView, didSelectQrCodeBtn btn: UIButton)
    /// 地图找房
    func topView(_ topView: HomeTopView, didSelectMapBtn btn: UIButton)
    /// 搜索
    func topView(_ topView: HomeTopView, didSearchWithTF textField: UITextField)
}

class HomeTopView: UIView {
    
    weak var delegate: HomeTopViewDelegate?
    
    @IBOutlet private weak var cityLB: UILabel!
    
    @IBOutlet private weak var topView: UIView!
    
    @IBOutlet private weak var bottomView: UIView!
    
    @IBOutlet private weak var btnsViewBg: UIView!
    /// -46  0
    @IBOutlet private weak var bottomLC: NSLayoutConstraint!
    
    @IBOutlet private weak var sourceView: UIView!
    
    @IBOutlet private weak var inputTF: UITextField!
    
    @IBOutlet weak var cityArrowIV: UIImageView!
    
    @IBOutlet weak var cityBtn: UIButton!
    
    private var ifTop = true
    
    private lazy var btnsView: ScrollBtnView = {
        let handelr: (Int)->() = { [unowned self] index in
            self.delegate?.topView(self, didChangeType: index)
        }
        let view = ScrollBtnView(.scale, frame: btnsViewBg.bounds, block: handelr)
        view.btns = ["我要买房", "我有房要卖"]
        view.font = dzy_Font(15)
        view.selectedFont = dzy_FontBlod(17)
        view.normalColor = dzy_HexColor(0x646464)
        view.selectedColor = dzy_HexColor(0x262626)
        view.selectedIndex = 0
        view.lineToBottom = 5
        view.hasLine = false
        view.isSelectedCanAction = false
        view.updateUI()
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    private func setUI() {
        btnsViewBg.addSubview(btnsView)
        inputTF.attributedPlaceholder = PublicConfig.publicSearchPlaceholder()
        inputTF.delegate = self
    }
    
    func updateUI(_ isSingle: Bool) {
        cityBtn.isHidden = isSingle
        cityArrowIV.isHidden = isSingle
    }
    
    func changeIdentity(_ index: Int) {
        btnsView.updateSelectedBtn(index)
    }
    
    func getIdentity() -> Int {
        return btnsView.selectedIndex == 0 ? 10 : 20
    }
    
    func updateCity(_ city:String) {
        cityLB.text = city
    }
    
    @IBAction func cityAction(_ sender: UIButton) {
        delegate?.topView(self, didSelectCityBtn: sender)
    }
    
    @IBAction func qrCodeAction(_ sender: UIButton) {
        delegate?.topView(self, didSelectQrCodeBtn: sender)
    }
    
    @IBAction func mapAction(_ sender: UIButton) {
        delegate?.topView(self, didSelectMapBtn: sender)
    }
    
    func change(_ top: Bool) {
        if ifTop == top {return}
        if top {
            ifTop = true
            showTop()
        }else {
            ifTop = false
            showBottom()
        }
    }
    
    private func showTop() {
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomLC.constant = -46
            self.topView.alpha = 1
            self.bottomView.alpha = 0
            self.layoutIfNeeded()
        })
    }
    
    private func showBottom() {
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomLC.constant = 0
            self.topView.alpha = 0
            self.bottomView.alpha = 1
            self.layoutIfNeeded()
        })
    }
}

extension HomeTopView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.topView(self, didSearchWithTF: textField)
        return true
    }
}
