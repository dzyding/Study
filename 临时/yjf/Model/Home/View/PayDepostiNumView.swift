//
//  PayDepostiNumView.swift
//  YJF
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class PayDepostiNumView: UIView {
    
    private weak var numLB: UILabel?
    /// 数字改变时的调用
    var changeNumHandler: ((Int) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }
    
    func setNum(_ num: Int) {
        numLB?.text = "\(num)"
    }
    
    private func setUI() {
        let reduceBtn = UIButton(type: .custom)
        reduceBtn.setImage(UIImage(named: "pay_deposti_reduce"), for: .normal)
        reduceBtn.addTarget(self, action: #selector(reduceAction), for: .touchUpInside)
        addSubview(reduceBtn)
        
        let addBtn = UIButton(type: .custom)
        addBtn.setImage(UIImage(named: "pay_deposti_add"), for: .normal)
        addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        addSubview(addBtn)
        
        let label = UILabel()
        label.font = dzy_Font(12)
        label.text = "1"
        label.textAlignment = .center
        addSubview(label)
        self.numLB = label
        
        reduceBtn.snp.makeConstraints { (make) in
            make.left.bottom.top.equalTo(0)
            make.width.equalTo(30)
        }
        
        addBtn.snp.makeConstraints { (make) in
            make.top.bottom.right.equalTo(0)
            make.width.equalTo(30)
        }
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(reduceBtn.snp.right)
            make.right.equalTo(addBtn.snp.left)
            make.top.bottom.equalTo(0)
        }
    }
    
    @objc private func reduceAction() {
        if let numStr = numLB?.text,
            let num = Int(numStr),
            num > 0
        {
            let result = num - 1
            numLB?.text = "\(result)"
            changeNumHandler?(result)
        }
    }
    
    @objc private func addAction() {
        if let numStr = numLB?.text,
            let num = Int(numStr)
        {
            let result = num + 1
            numLB?.text = "\(result)"
            changeNumHandler?(result)
        }
    }
}
