//
//  BIHCurrentView.swift
//  PPBody
//
//  Created by edz on 2020/5/18.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class BIHCurrentView: UIView, InitFromNibEnable {

    @IBOutlet weak var mLowLB: UILabel!
    @IBOutlet weak var mMidLB: UILabel!
    @IBOutlet weak var mHighLB: UILabel!
    
    @IBOutlet weak var msgLB: UILabel!
    
    @IBOutlet weak var lowCurrentLB: UILabel!
    
    @IBOutlet weak var lowCurrentView: UIView!
    
    @IBOutlet weak var lowValueLB: UILabel!
    
    @IBOutlet weak var lowLeftLC: NSLayoutConstraint!
    
    @IBOutlet weak var midCurrentView: UIView!
    
    @IBOutlet weak var midCurrentLB: UILabel!
    
    @IBOutlet weak var midValueLB: UILabel!
    
    @IBOutlet weak var midLeftLC: NSLayoutConstraint!
    
    @IBOutlet weak var highCurrentView: UIView!
    
    @IBOutlet weak var highCurrentLB: UILabel!
    
    @IBOutlet weak var highValueLB: UILabel!
    
    @IBOutlet weak var highLeftLC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msgLB.font = dzy_FontBlod(15)
        [lowCurrentLB, midCurrentLB, highCurrentLB].forEach { (label) in
            label?.font = dzy_FontBBlod(15)
        }
        [mLowLB, lowValueLB, mMidLB, midValueLB, mHighLB, highValueLB].forEach { (label) in
            label?.font = dzy_FontBlod(10)
        }
    }
    
    func updateUI(_ type: BodyStatusType,
                  min: Double,
                  max: Double,
                  low: Double,
                  high: Double,
                  current: Double,
                  unit: String
    ) {
        switch type {
        case .Weight:
            msgLB.text = "当前体重（\(unit)）"
        case .Muscle:
            msgLB.text = "当前骨骼肌（\(unit)）"
        case .Fat:
            msgLB.text = "当前脂肪（\(unit)）"
        default:
            break
        }
        [
            lowCurrentView, lowCurrentLB,
            midCurrentView, midCurrentLB,
            highCurrentView, highCurrentLB
        ].forEach({
            $0?.isHidden = true
        })
        lowValueLB.text = min.decimalStr + "~" + low.decimalStr + unit
        midValueLB.text = low.decimalStr + "~" + high.decimalStr + unit
        highValueLB.text = high.decimalStr + "~" + max.decimalStr + unit
        if current > min && current < low {
            lowCurrentView.isHidden = false
            lowCurrentLB.isHidden = false
            lowCurrentLB.text = current.decimalStr
            let width = (lowCurrentLB.superview?.frame.width ?? 3)
            let left = CGFloat((current - min) / (low - min)) * width - 5
            lowLeftLC.constant = left
        }else if current >= low && current <= high {
            midCurrentView.isHidden = false
            midCurrentLB.isHidden = false
            midCurrentLB.text = current.decimalStr
            let width = (midCurrentLB.superview?.frame.width ?? 3)
            let left = CGFloat((current - low) / (high - low)) * width - 3
            midLeftLC.constant = left
        }else {
            highCurrentView.isHidden = false
            highCurrentLB.isHidden = false
            highCurrentLB.text = current.decimalStr
            let width = (highCurrentLB.superview?.frame.width ?? 3)
            let left = CGFloat((current - high) / (max - high)) * width + 5
            highLeftLC.constant = left
        }
    }
}
