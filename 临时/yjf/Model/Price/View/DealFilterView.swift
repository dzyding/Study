//
//  DealFilterView.swift
//  YJF
//
//  Created by edz on 2019/7/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol DealFilterViewDelegate: class {
    func filterView(_ filterView: DealFilterView, didClickSureBtn btn: UIButton, count: Int)
    func filterView(_ filterView: DealFilterView, didClickClearBtn btn: UIButton)
}

class DealFilterView: UIView {
    
    weak var delegate: DealFilterViewDelegate?
    
    @IBOutlet private weak var stackView: UIStackView!
    
    var floorMsg: (Int, Int)?
    
    var timeMsg: (String, String)?
    /// 单价
    var sPriceMsg: (Double, Double)?
    /// 总价
    var tPriceMsg: (Double, Double)?
    
    func reset() {
        floorMsg = nil
        timeMsg = nil
        sPriceMsg = nil
        tPriceMsg = nil
        floorView.reset()
        timeView.reset()
        sPriceView.reset()
        tPriceView.reset()
    }
    
    @IBAction private func resetAction(_ sender: UIButton) {
        delegate?.filterView(self, didClickClearBtn: sender)
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        var filterCount = 0
        if let floor = floorView.selectedFloorMsg() {
            filterCount += 1
            floorMsg = floor
        }
        if let time = timeView.selectedTimeMsg() {
            filterCount += 1
            timeMsg = time
        }
        if let sprice = sPriceView.selectedMsg() {
            filterCount += 1
            sPriceMsg = sprice
        }
        if let tprice = tPriceView.selectedMsg() {
            filterCount += 1
            tPriceMsg = tprice
        }
        delegate?.filterView(self, didClickSureBtn: sender, count: filterCount)
    }
    
    func initUI() {
        stackView.addArrangedSubview(floorView)
        stackView.addArrangedSubview(timeView)
        stackView.addArrangedSubview(sPriceView)
        stackView.addArrangedSubview(tPriceView)
    }
    
    //    MARK: - 懒加载
    private lazy var floorView: DealNoInputFilterSbView = {
        let view = DealNoInputFilterSbView
            .initFromNib(DealNoInputFilterSbView.self)
        view.initUI(.floor)
        return view
    }()
    
    private lazy var timeView: DealNoInputFilterSbView = {
        let view = DealNoInputFilterSbView
            .initFromNib(DealNoInputFilterSbView.self)
        view.initUI(.time)
        return view
    }()
    
    private lazy var sPriceView: DealInputFilterSbView = {
        let view = DealInputFilterSbView
            .initFromNib(DealInputFilterSbView.self)
        view.initUI(.sPrice)
        return view
    }()
    
    private lazy var tPriceView: DealInputFilterSbView = {
        let view = DealInputFilterSbView
            .initFromNib(DealInputFilterSbView.self)
        view.initUI(.tPrice)
        return view
    }()
}
