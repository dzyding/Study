//
//  HomeTableHeaderView.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

enum FunType: Int {
    /// 如何看房
    case howLook = 1
    /// 我的竞买
    case myBuy
    /// 贷款计算
    case loans
    /// 如何发布房源
    case howRelease
    /// 买房税费
    case buyCompute
    /// 卖房税费
    case sellCompute
    /// 常见问题
    case commonAns
    /// 智能问答
    case smartQA
}

protocol HomeTableHeaderViewDelegate: class {
    func header(_ headerView: HomeTableHeaderView, didSelectFun type: Int)
    func header(_ headerView: HomeTableHeaderView, didSelectMapBtn btn: UIButton)
    func header(_ headerView: HomeTableHeaderView, didSelectQrBtn btn: UIButton)
    func header(_ headerView: HomeTableHeaderView, didSearchWithTF textField: UITextField)
    func header(_ headerView: HomeTableHeaderView, didSelectAdView page: Int)
}

class HomeTableHeaderView: UIView {

    @IBOutlet weak var bannersBg: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var inputTF: UITextField!
    // 扫一扫
    @IBOutlet weak var qrBtn: UIButton!
    
    weak var delegate: HomeTableHeaderViewDelegate?
    /// 是否隐藏
    private var isHid = false
    
    private lazy var adView: DzyAdView = {
        let view = DzyAdView(bannersBg.bounds, pageType: .rect)
        view.handler = { [unowned self] page in
            self.delegate?.header(self, didSelectAdView: page)
        }
        return view
    }()
    
    private var type: Identity?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateQrBtn()
        let attStr = PublicConfig.homeHeaderSearchPlaceholder()
        inputTF.attributedPlaceholder = attStr
        inputTF.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.bannersBg.addSubview(self.adView)
        }
    }
    
    func updateBanner(_ datas: [[String : Any]]) {
        let covers = datas.compactMap({$0.stringValue("cover")})
        adView.updateUI(covers)
    }
    
    func updateQrBtn() {
        if isHid {return}
        PublicFunc.updateUserDetail { [weak self] (_, _, data) in
            data.intValue("scanCountType").flatMap({
                self?.isHid = $0 == 20
                self?.qrBtn.isHidden = $0 == 20
            })
        }
    }
    
    func setUI(_ type: Identity) {
        if self.type == type {return}
        self.type = type
        while stackView.arrangedSubviews.count > 0 {
            if let view = stackView.arrangedSubviews.last {
                view.removeFromSuperview()
            }
        }
        let arr: [(String, String, FunType)] = {
            type == .buyer ? [
                ("如何看房", "home_fun_kf", .howLook),
                ("我的竞买", "home_fun_jm", .myBuy),
                ("贷款计算", "home_fun_dkjs", .loans),
                ("买房税费计算", "home_fun_buy", .buyCompute),
                ("卖房税费计算", "home_fun_sell", .sellCompute)
                ] : [
                ("如何卖房", "home_fun_public", .howRelease),
                ("买房税费计算", "home_fun_buy", .buyCompute),
                ("卖房税费计算", "home_fun_sell", .sellCompute),
                ("贷款计算", "home_fun_dkjs", .loans)
            ]
        }()
        arr.forEach { (model) in
            let view = HomeTableHeaderBtnView
                .initFromNib(HomeTableHeaderBtnView.self)
            view.updateUI(model)
            view.handler = { [unowned self] type in
                self.delegate?.header(self, didSelectFun: type.rawValue)
            }
            stackView.addArrangedSubview(view)
        }
    }

    @IBAction func mapAction(_ sender: UIButton) {
        delegate?.header(self, didSelectMapBtn: sender)
    }
    
    // 扫一扫
    @IBAction func qrAction(_ sender: UIButton) {
        delegate?.header(self, didSelectQrBtn: sender)
    }
}

extension HomeTableHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.header(self, didSearchWithTF: textField)
        return true
    }
}
