//
//  CoachReduceCourseView.swift
//  PPBody
//
//  Created by edz on 2019/7/27.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

protocol CoachReduceCourseViewDelegate: class {
    func courseView(_ courseView: CoachReduceCourseView, didSelectedRow row: Int)
}

class CoachReduceCourseView: UIView {
    
    weak var delegate: CoachReduceCourseViewDelegate?
    
    var data: [String : Any] = [:]
    
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    private var row: Int = 0
    
    override func awakeFromNib() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectAction(_:))))
    }
    
    func updateUI(_ data: [String : Any], row: Int) {
        self.data = data
        self.row = row
        btn.isSelected = data.boolValue("isSelected") == true
        nameLB.text = data.stringValue("name")
        numLB.text = "\(data.intValue("num") ?? 0)节"
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        delegate?.courseView(self, didSelectedRow: row)
    }
}
