//
//  RegisterHeightweightView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RegisterHeightweightView: UIView {
    
    
    @IBOutlet weak var heightLB: UILabel!
    @IBOutlet weak var heightView: NaRulerView!
    
    @IBOutlet weak var weightLB: UILabel!
    @IBOutlet weak var weightView: NaRulerView!
    
    var nextAction:(()->())?
    
    class func instanceFromNib() -> RegisterHeightweightView {
        return UINib(nibName: "RegisterProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[5] as! RegisterHeightweightView
    }
    
    override func awakeFromNib() {
        heightView.rulerScrollView.highColor = Text1Color
        heightView.rulerScrollView.lowColor = Text1Color
        heightView.rulerScrollView.normalColor = Text1Color
        
        heightView.showRulerScrollViewWithCount(130, max: 200, lowCount: nil, highCount: nil, average: 1, currentValue: 160, smallMode: true)
        
        heightView.delegate = self
        
        self.heightLB.text = String.init(format: "%.fcm", locale: Locale.current, arguments: [(heightView.rulerScrollView.rulerValue + CGFloat(heightView.rulerScrollView.min)) as CVarArg])
        
        weightView.rulerScrollView.highColor = Text1Color
        weightView.rulerScrollView.lowColor = Text1Color
        weightView.rulerScrollView.normalColor = Text1Color
        
        weightView.showRulerScrollViewWithCount(30, max: 130, lowCount: nil, highCount: nil, average: 1, currentValue: 50, smallMode: true)
        
        weightView.delegate = self
        
        self.weightLB.text = String.init(format: "%.fkg", locale: Locale.current, arguments: [(weightView.rulerScrollView.rulerValue + CGFloat(weightView.rulerScrollView.min)) as CVarArg])
    }
    
    func getHeightWeight() -> (height:String, weight:String)
    {
        let height = self.heightLB.text?.replacingOccurrences(of: "cm", with: "")
        let weight = self.weightLB.text?.replacingOccurrences(of: "kg", with: "")
        return (height!,weight!)
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        self.nextAction!()
    }
    
}

extension RegisterHeightweightView: NaRulerViewDelegate {
    
    func naRulerView(scroll: NaRulerScrollView) {
        
        if scroll.superview == heightView {
            self.heightLB.text = String.init(format: "%.fcm", locale: Locale.current, arguments:  [(scroll.rulerValue + CGFloat(scroll.min)) as CVarArg])
        }else if scroll.superview == weightView{
            
            self.weightLB.text = String.init(format: "%.fkg", locale: Locale.current, arguments:  [(scroll.rulerValue + CGFloat(scroll.min)) as CVarArg])
        }
        
    }
}
