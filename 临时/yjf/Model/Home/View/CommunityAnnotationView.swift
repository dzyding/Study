//
//  CommunityAnnotationView.swift
//  YJF
//
//  Created by edz on 2019/7/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CommunityAnnotationView: MAAnnotationView {
    
    private weak var imgView: UIImageView?
    
    private weak var detailLB: UILabel?
    
    private weak var titleLB: UILabel?
    
    var data: [String : Any] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 125, height: 61))
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
        let price = data.doubleValue("price") ?? 0
        detailLB?.text = "\(houseNum)套" + " 均价" + price.decimalStr + "万"
    }
    
    func updateImg(_ isSelected: Bool) {
        let name = isSelected ?
            "map_search_house" : "map_search_house_no"
        imgView?.image = UIImage(named: name)
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
        let imgView = UIImageView(image: UIImage(named: "map_search_house_no"))
        addSubview(imgView)
        self.imgView = imgView
        
        let detailLB = getLabel()
        addSubview(detailLB)
        self.detailLB = detailLB
        
        let titleLB = getLabel()
        addSubview(titleLB)
        self.titleLB = titleLB
        
        imgView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets.zero)
        }
        
        titleLB.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-10)
            make.left.equalTo(20)
        }
        
        detailLB.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(7)
            make.left.equalTo(20)
        }
    }
}
