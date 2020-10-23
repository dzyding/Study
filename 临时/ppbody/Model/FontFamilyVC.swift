//
//  FontFamilyVC.swift
//  PPBody
//
//  Created by edz on 2020/5/26.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class FontFamilyVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var fonts: [UIFont] = {
        var arr: [UIFont] = []
        UIFont.familyNames.forEach { (fname) in
            let fonts = UIFont.fontNames(forFamilyName: fname)
                .compactMap({
                UIFont(name: $0, size: 30)
            })
            arr.append(contentsOf: fonts)
        }
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension FontFamilyVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        let font = fonts[indexPath.row]
        cell?.textLabel?.font = font
        cell?.textLabel?.text = "123"
        cell?.detailTextLabel?.text = font.familyName + "_" + font.fontName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let font = fonts[indexPath.row]
        print(font.familyName + "_" + font.fontName)
    }
}
