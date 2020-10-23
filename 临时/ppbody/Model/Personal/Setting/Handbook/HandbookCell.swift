//
//  HandbookCell.swift
//  PPBody
//
//  Created by Nathan_he on 2018/8/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class HandbookCell: UITableViewCell {
    
    @IBOutlet weak var questionLB: UILabel!
    @IBOutlet weak var answerLB: UILabel!
    
    override func awakeFromNib() {
        self.questionLB.preferredMaxLayoutWidth = ScreenWidth - 58
        self.answerLB.preferredMaxLayoutWidth = ScreenWidth - 58
    }
    
    func setData(_ dic:[String:Any])
    {
        self.questionLB.text = dic["question"] as? String
        self.answerLB.text = dic["answer"] as? String
    }
}
