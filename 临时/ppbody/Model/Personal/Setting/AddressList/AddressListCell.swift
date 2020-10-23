//
//  AddressListCell.swift
//  PPBody
//
//  Created by edz on 2019/11/11.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class AddressListCell: UITableViewCell {
    
    var handler: (()->())?

    @IBOutlet weak var nameLB: UILabel!
    
    @IBOutlet weak var mobileLB: UILabel!
    
    @IBOutlet weak var addressLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ data: [String : Any]) {
        nameLB.text = data.stringValue("name")
        mobileLB.text = data.stringValue("mobile")
        var area = data.stringValue("area") ?? ""
        let address = data.stringValue("address") ?? ""
        area = area.replacingOccurrences(of: " ", with: "")
        addressLB.text = area + address
    }
    
    @IBAction private func editAction(_ sender: Any) {
        handler?()
    }
    
}
