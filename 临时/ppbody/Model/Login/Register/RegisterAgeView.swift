//
//  RegisterAgeView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RegisterAgeView: UIView {
    
    @IBOutlet weak var ageLB: UILabel!
    @IBOutlet weak var ageView: NaRulerView!
    @IBOutlet weak var okBtn: UIButton!
    
    var registAction:(()->())?
    
    class func instanceFromNib() -> RegisterAgeView {
        return UINib(nibName: "RegisterProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[6] as! RegisterAgeView
    }
    
    override func awakeFromNib() {
        ageView.rulerScrollView.highColor = Text1Color
        ageView.rulerScrollView.lowColor = Text1Color
        ageView.rulerScrollView.normalColor = Text1Color
        
        ageView.showRulerScrollViewWithCount(12, max: 72, lowCount: nil, highCount: nil, average: 1, currentValue: 25, smallMode: true)
        
        ageView.delegate = self
        
        self.ageLB.text = String.init(format: "%.f岁", locale: Locale.current, arguments: [(ageView.rulerScrollView.rulerValue + CGFloat(ageView.rulerScrollView.min))  as CVarArg])
    }
    
    func getAge() -> String
    {
        let age = self.ageLB.text?.replacingOccurrences(of: "岁", with: "")
        return age!
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        registAction?()
    }
    
    func isEnable(_ enable: Bool) {
        okBtn.isEnabled = enable
    }
}

extension RegisterAgeView: NaRulerViewDelegate {
    
    func naRulerView(scroll: NaRulerScrollView) {
        
        self.ageLB.text = String.init(format: "%.f岁", locale: Locale.current, arguments:  [(scroll.rulerValue + CGFloat(scroll.min)) as CVarArg])
        
    }
}
