//
//  DealFilterHeaderView.swift
//  YJF
//
//  Created by edz on 2019/7/2.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol DealFilterHeaderViewDelegate: class {
    func filterHeader(_ filterHeader: DealFilterHeaderView, didSelect type: String)
    func filterHeader(_ filterHeader: DealFilterHeaderView, didSelectOrderBtn btn: UIButton)
}

class DealFilterHeaderView: UIView {
    
    private let titles: [FilterType] = [.district, .houseType, .area, .filter]

    @IBOutlet private weak var orderBtn: UIButton!
    
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: DealFilterHeaderViewDelegate?
    
    var showType: FilterType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    private func setUI() {
        titles.enumerated().forEach { (_, title) in
            let view = FilterBtnView()
            view.titleLB?.text = title.rawValue
            view.handler = { [unowned self] in
                self.delegate?.filterHeader(self, didSelect: title.rawValue)
            }
            stackView.addArrangedSubview(view)
        }
    }
    
    @IBAction func orderAction(_ sender: UIButton) {
        sender.isSelected = true
        delegate?.filterHeader(self, didSelectOrderBtn: sender)
    }
    
    //    MARK: - 更改对应 index 的title
    func setTilte(_ index: Int, title: String?) {
        if index == 3 {
            if let view = stackView.arrangedSubviews.last as? FilterBtnView {
                view.isSelected = title != nil
            }
        }else if index == 4 {
            orderBtn.isSelected = title != nil
        }else if let btnView = stackView.arrangedSubviews[index] as? FilterBtnView {
            if title == nil {
                var temp: String = ""
                switch index {
                case 0:
                    temp = "区域"
                case 1:
                    temp = "户型"
                default:
                    temp = "面积"
                }
                btnView.titleLB?.text = temp
                btnView.isSelected = false
            }else {
                btnView.titleLB?.text = title
                btnView.isSelected = true
            }
        }
    }

}
