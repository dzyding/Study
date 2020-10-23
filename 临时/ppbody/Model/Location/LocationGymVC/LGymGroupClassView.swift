//
//  LGymGroupClassView.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol LGymGroupClassViewDelegate: class {
    func classView(_ classView: LGymGroupClassView,
                   didReserveData data: [String : Any])
}

class LGymGroupClassView: UIView, InitFromNibEnable {
    
    weak var delegate: LGymGroupClassViewDelegate?

    @IBOutlet weak var dateStackView: UIStackView!
    
    @IBOutlet weak var classStackView: UIStackView!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var lineLeftLC: NSLayoutConstraint!
    
    private lazy var dates = LocationVCHelper.getNextNumDates(6)
    
    func initUI() {
        dates.enumerated().forEach({ (index, value) in
            let cell = LGymGCDateCell.initFromNib()
            cell.tag = index
            cell.updateUI(value)
            cell.handler = { [weak self] tag in
                self?.btnAction(tag)
            }
            dateStackView.addArrangedSubview(cell)
        })
    }
    
    func updateUI(_ count: Int) {
        stackViewHeightLC.constant = 85.0 * CGFloat(count)
        (0..<count).forEach { (index) in
            let cell = LGymGCClassCell.initFromNib()
            cell.reserveHandler = { [weak self] in
                self?.reserveAction([:])
            }
            cell.initUI()
            classStackView.addArrangedSubview(cell)
        }
    }
    
//    MARK: - 预约
    private func reserveAction(_ data: [String : Any]) {
        delegate?.classView(self, didReserveData: data)
    }
    
//    MARK: - 选择日期
    private func btnAction(_ tag: Int) {
        guard let cell = dateStackView.arrangedSubviews[tag] as? LGymGCDateCell else {return}
        lineLeftLC.constant = cell.frame.minX
        UIView.animate(withDuration: 0.25) {
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
        }
        
        (0..<dates.count).forEach { (index) in
            dates[index].2 = false
        }
        dates[tag].2 = true
        (0..<dates.count).forEach { (index) in
            let cell = (dateStackView.arrangedSubviews[index] as? LGymGCDateCell)
            cell?.updateUI(dates[index])
        }
    }
}
