//
//  VarietyLabelCellProtocol.swift
//  PPBody
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

protocol VarietyLabelCellProtocol where Self: UIView {
    static func create(_ title: String, handler: ()->(CGFloat)) -> Self
}
