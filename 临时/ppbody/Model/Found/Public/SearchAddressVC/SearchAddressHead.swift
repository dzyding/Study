//
//  SearchAddressHead.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class SearchAddressHead: UIView {
    
    @IBOutlet weak var noneView: UIView!
    weak var delegate: SelectAddressDelegate?
    
    class func instanceFromNib() -> SearchAddressHead {
        return UINib(nibName: "SearchAddressHead", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchAddressHead
    }
    
    override func awakeFromNib() {
        self.noneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noneAction)))
    }
    
    @objc func noneAction()
    {
        self.delegate?.selectAddress([String:String]())
        ToolClass.controller2(view: self)?.navigationController?.popViewController(animated: true)
    }
}
