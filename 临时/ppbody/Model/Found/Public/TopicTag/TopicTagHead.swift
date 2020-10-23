//
//  TopicTagHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicTagHead: UIView {
    
    @IBOutlet weak var noneView: UIView!
    
    weak var delegate: SelectTopicTagDelegate?

    override func awakeFromNib() {
        noneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noneAction)))
    }
    
    @objc func noneAction() {
        delegate?.selectTag("")
        ToolClass.controller2(view: self)?.navigationController?.popViewController(animated: true)
    }
}
