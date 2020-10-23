//
//  NewsListCell.swift
//  YJF
//
//  Created by edz on 2019/8/12.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class NewsListCell: UITableViewCell {

    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var readNumLB: UILabel!
    
    @IBOutlet weak var imageIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        nameLB.text = data.stringValue("title")
        let num = data.intValue("num") ?? 0
        readNumLB.text = "\(num)次阅读"
        readNumLB.isHidden = num == 0
        imageIV.setCoverImageUrl(data.stringValue("cover"))
        if let time = data.stringValue("createTime")?
            .components(separatedBy: " ").first
        {
            let index = time.index(time.startIndex, offsetBy: 5)
            timeLB.text = String(time[index...])
        }else {
            timeLB.text = nil
        }
    }
}
