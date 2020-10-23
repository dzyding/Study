//
//  MapAnnotation.swift
//  YJF
//
//  Created by edz on 2019/6/10.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class CustomMapAnnotationView: MAAnnotationView {
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 101, height: 46))
        setUI()
    }
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .clear
        let imgView = UIImageView(image: UIImage(named: "house_detail_map_anno"))
        addSubview(imgView)

        let titleLB = UILabel()
        titleLB.text = "房源位置"
        titleLB.textColor = .white
        titleLB.font = dzy_Font(13)
        titleLB.backgroundColor = .clear
        addSubview(titleLB)

        imgView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets.zero)
        }

        titleLB.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-3)
        }
    }
}
