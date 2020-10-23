//
//  WatchHouseSellerCell.swift
//  YJF
//
//  Created by edz on 2019/5/9.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol WatchHouseSellerCellDelegate: class {
    func sellerCell(_ sellerCell: WatchHouseSellerCell, didSelectEquip row: Int)
}

class WatchHouseSellerCell: UITableViewCell {
    
    weak var delegate: WatchHouseSellerCellDelegate?

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.backgroundColor = .white
    }
    
    @objc private func btnAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        delegate?.sellerCell(self, didSelectEquip: btn.tag)
    }
    
    func updateUI(_ titles: [[String : Any]]) {
        var totalWidth: CGFloat = 0
        var widths: [CGFloat] = []
        let padding: CGFloat = 5.0
        titles.forEach { (dic) in
            let str = dic.stringValue("name") ?? ""
            var width = dzy_strSize(str: str, font: dzy_Font(14)).width
            width += 20
            width = max(75.0, width)
            widths.append(width)
            totalWidth += width
        }
        totalWidth += CGFloat(titles.count) * padding // 间隔
        totalWidth += 36.0 //两个开始的空白
        
        // 第一行的最大宽度
        var firstMax: CGFloat = 0
        // 第二行的最大宽度
        var secondMax: CGFloat = 0
        
        var x: CGFloat = 18.0
        var y: CGFloat = 20.0
        titles.enumerated().forEach { (index, dic) in
            let selected = dic.boolValue(Public_isSelected) ?? false
            let width = widths[index]
            let title = dic.stringValue("name") ?? ""
            
            let btn = UIButton(type: .custom)
            btn.tag = index
            btn.isSelected = selected
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = dzy_Font(14)
            btn.setTitleColor(Font_Dark, for: .normal)
            btn.setTitleColor(dzy_HexColor(0xFF7400), for: .selected)
            btn.frame = CGRect(x: x, y: y, width: width, height: 25.0)
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btn.setBackgroundImage(UIImage(named: "watch_seller_selected_no"), for: .normal)
            btn.setBackgroundImage(UIImage(named: "watch_seller_selected"), for: .selected)
            scrollView.addSubview(btn)
            
            x += (width + padding)
            // 如果长度超过了一般，并且还没换行
            if totalWidth >= ScreenWidth && (x > totalWidth / 2.0) && firstMax == 0 {
                firstMax = x
                // 换行
                x = 18.0
                y = 55.0
            }
            
            if index == titles.count - 1 {
                secondMax = x
            }
        }
        scrollView.contentSize = CGSize(width: max(firstMax, secondMax), height: 95.0)
    }
}
