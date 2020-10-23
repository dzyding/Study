//
//  CircularAnnotationView.swift
//  YJF
//
//  Created by edz on 2019/7/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CircularAnnotationView: MAAnnotationView {
    
    private weak var numLB: UILabel?
    
    private weak var titleLB: UILabel?
    
    private weak var priceLB: UILabel?
    
    var data: [String : Any] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 81, height: 81))
        setUI()
    }
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(_ data: [String : Any]) {
        self.data = data
        titleLB?.text = data.stringValue("name")
        let houseNum = data.intValue("houseNum") ?? 0
        numLB?.text = "\(houseNum)套"
        let price = data.doubleValue("price") ?? 0
        priceLB?.text = "均价" + price.decimalStr + "万"
    }
    
    private func setUI() {
        func getLabel() -> UILabel {
            let lb = UILabel()
            lb.textColor = .white
            lb.font = dzy_Font(11)
            lb.backgroundColor = .clear
            lb.textAlignment = .center
            return lb
        }
        backgroundColor = .clear
        let imgView = UIImageView(image: UIImage(named: "map_search_circular"))
        addSubview(imgView)
        
        let numLB = getLabel()
        addSubview(numLB)
        self.numLB = numLB
        
        let priceLB = getLabel()
        addSubview(priceLB)
        self.priceLB = priceLB
        
        let titleLB = getLabel()
        addSubview(titleLB)
        self.titleLB = titleLB
        
        imgView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets.zero)
        }
        
        numLB.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
            make.left.equalTo(5)
        }
        
        titleLB.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(numLB.snp.top).offset(-6)
            make.left.equalTo(10)
        }
        
        priceLB.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(numLB.snp.bottom).offset(6)
            make.left.equalTo(10)
        }
    }
}
