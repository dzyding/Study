//
//  MapMarkView.swift
//  ZHYQ-FsZc
//
//  Created by edz on 2019/1/23.
//  Copyright © 2019 dzy. All rights reserved.
//

import UIKit

class MapMarkView: UIView {

    @IBOutlet weak var mark: UIImageView!
    
    @IBOutlet weak var circle: UIImageView!
    
    func start() {
        UIView.animate(withDuration: 0.5) {
            self.mark.transform = self.mark.transform.translatedBy(x: 0, y: -10)
            self.circle.transform = self.circle.transform.scaledBy(x: 0.5, y: 0.5)
        }
    }
    
    func end() {
        UIView.animate(withDuration: 0.5) {
            self.mark.transform = .identity
            self.circle.transform = .identity
        }
    }
}
