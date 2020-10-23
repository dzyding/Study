//
//  TableViewExtension.swift
//  HousingMarket
//
//  Created by 朱帅 on 2018/11/26.
//  Copyright © 2018 远坂凛. All rights reserved.
//

import Foundation
import UIKit

extension UITableView{
     func dzy_registerCellNib<T: UITableViewCell>(_ aClass: T.Type) {
          let name = String(describing: aClass)
          let nib = UINib(nibName: name, bundle: nil)
          self.register(nib, forCellReuseIdentifier: name)
     }
     
     func dzy_registerCellClass<T: UITableViewCell>(_ aClass: T.Type) {
          let name = String(describing: aClass)
          self.register(aClass, forCellReuseIdentifier: name)
     }
     
     func dzy_dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type) -> T! {
          let name = String(describing: aClass)
          guard let cell = dequeueReusableCell(withIdentifier: name) as? T else {
               print(name)
               fatalError("\(name) is not registed")
          }
          cell.selectionStyle = .none
          return cell
     }
     
     func dzy_registerHeaderFooterClass<T: UITableViewHeaderFooterView>(_ aClass: T.Type) {
          let name = String(describing: aClass)
          let nib = UINib(nibName: name, bundle: nil)
          register(nib, forHeaderFooterViewReuseIdentifier: name)
     }
     
     func dzy_dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(_ aClass: T.Type) -> T {
          let name = String(describing: aClass)
          guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: name) as? T else {
               fatalError("\(name) is not registed")
          }
          return headerFooter
     }
}
