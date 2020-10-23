//
//  TrainDataView.swift
//  PPBody
//
//  Created by edz on 2019/12/18.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol TrainDataViewDelegate: class {
    func dateView(_ dataView: TrainDataView,
                  didSelectDetailBtn btn: UIButton)
    
    func dateView(_ dataView: TrainDataView,
                  didSelectHistoryBtn btn: UIButton)
}

class TrainDataView: UIView, InitFromNibEnable {
    
    weak var delegate: TrainDataViewDelegate?
    
    @IBOutlet weak var mTotalLB: UILabel!
    @IBOutlet weak var mWeekLB: UILabel!
    @IBOutlet weak var mHistoryLB: UILabel!
    @IBOutlet weak var mDunLB: UILabel!
    @IBOutlet weak var mStackView: UIStackView!
    
    @IBOutlet weak var totalLB: UILabel!
    
    @IBOutlet weak var totalDayLB: UILabel!
    
    @IBOutlet weak var totalNumLB: UILabel!
    
    @IBOutlet weak var totalTimeLB: UILabel!
    
    @IBOutlet weak var weekDataView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        totalLB.font = dzy_FontNumber(36)
        [totalDayLB, totalNumLB, totalTimeLB].forEach { (label) in
            label?.font = dzy_FontNumber(18)
        }
        [mTotalLB, mWeekLB, mHistoryLB, mDunLB].forEach { (label) in
            label?.font = dzy_FontBlod(12)
        }
        mStackView.arrangedSubviews.forEach { (view) in
            (view.viewWithTag(99) as? UILabel)?.font = dzy_FontBlod(12)
        }
    }
    
    func updateUI(_ total: [String : Any], weakt: [Int]) {
        totalLB.text = (total.doubleValue("totalWeight") ?? 0).decimalStr
        totalDayLB.text = "\(total.intValue("totalDays") ?? 0)"
        totalNumLB.text = "\(total.intValue("totalNum") ?? 0)"
        totalTimeLB.text = "\(total.intValue("totalTime") ?? 0)"
        
        assert(weekDataView.arrangedSubviews.count == weakt.count)
        weekDataView.arrangedSubviews.enumerated().forEach { (index, view) in
            if let sview = view.viewWithTag(9) {
                sview.snp.updateConstraints { (make) in
                    let height = CGFloat(weakt[index]) / 100.0 * 65.0
                    make.height.equalTo(height)
                }
            }
        }
    }

    @IBAction func detailAction(_ sender: UIButton) {
        delegate?.dateView(self, didSelectDetailBtn: sender)
    }
    
    @IBAction func histortAction(_ sender: UIButton) {
        delegate?.dateView(self, didSelectHistoryBtn: sender)
    }
}
