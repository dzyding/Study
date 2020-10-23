//
//  BodyIndexRulerView.swift
//  PPBody
//
//  Created by edz on 2020/5/20.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class BodyIndexRulerView: UIView, InitFromNibEnable {

    @IBOutlet weak var rulerView: NaRulerView!
    
    @IBOutlet weak var currentLB: UILabel!
    
    @IBOutlet weak var unitLB: UILabel!
    
    private var current: Float = 0
    
    var saveHandler: ((Float)->())?
    
    func updateUI(min: Int, max: Int, low: CGFloat, high: CGFloat, current: CGFloat, unit: String) {
        rulerView.delegate = self
        self.current = Float(current)
        currentLB.text = Double(current).decimalStr
        unitLB.text = unit
        rulerView.showRulerScrollViewWithCount(min, max: max, lowCount: low, highCount: high, average: 0.1, currentValue: current, smallMode: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        saveHandler?(current)
        (superview as? DzyPopView)?.hide()
    }
}

extension BodyIndexRulerView: NaRulerViewDelegate {
    func naRulerView(scroll: NaRulerScrollView) {
        current = Float(scroll.rulerValue + CGFloat(scroll.min)).format(f: 1)
        currentLB.text = String(format: "%.1f", current)
    }
}
