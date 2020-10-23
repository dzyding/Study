//
//  TrainTagSourceView.swift
//  PPBody
//
//  Created by edz on 2019/12/19.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TrainTagSourceView: UIView, InitFromNibEnable {

    @IBOutlet weak var imgIV: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var numLB: UILabel!
    
    private var handler: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLB.font = dzy_FontBlod(14)
        numLB.font = dzy_FontBlod(10)
    }
    
    func initUI(_ data: [String : Any],
                handler: @escaping ()->()) {
        self.handler = handler
        imgIV.setCoverImageUrl(data.stringValue("cover") ?? "")
        nameLB.text = "#\(data.stringValue("name") ?? "")#"
        numLB.text = "\(data.intValue("joinNum") ?? 0)人参与"
    }
    
    @IBAction func btnAction(_ sender: Any) {
        handler?()
    }
}
