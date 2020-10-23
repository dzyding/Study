//
//  HomeSectionHeader.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc protocol HomeSectionHeaderDelegate {
    func header(header: HomeSectionHeader, didSelect type: String)
}

enum FilterType: String {
    case houseType = "户型"
    case district = "区域"
    case price = "价格"
    case area = "面积"
    case filter = "筛选"
    case order = "排序"
    
    func getIndex() -> Int {
        switch self {
        case .district:
            return 0
        case .houseType:
            return 1
        case .area:
            return 2
        case .price:
            return 3
        case .filter:
            return 3
        case .order:
            return 4
        }
    }
}

class HomeSectionHeader: UIView {
    
    private let titles: [FilterType] = [.district, .houseType, .area, .price]

    @IBOutlet weak var stackView: UIStackView!
    
    weak var delegate: HomeSectionHeaderDelegate?
    
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
                self.delegate?.header(header: self, didSelect: title.rawValue)
            }
            stackView.addArrangedSubview(view)
        }
    }
    
    //    MARK: - 更改对应 index 的title
    func setTilte(_ index: Int, title: String?) {
        if let btnView = stackView.arrangedSubviews[index] as? FilterBtnView {
            if title == nil {
                var temp: String = ""
                switch index {
                case 0:
                    temp = "区域"
                case 1:
                    temp = "户型"
                case 2:
                    temp = "面积"
                default:
                    temp = "价格"
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
