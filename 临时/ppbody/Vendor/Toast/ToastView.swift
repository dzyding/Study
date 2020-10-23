//
//  ToastView.swift
//  ButteryToast
//
//  Created by creisterer on 11/3/15.
//  Copyright © 2015 Starry. All rights reserved.
//

import UIKit

/**
 Container view for views presented in a Toast.
 Useful for providing default styling for all toasts (for example, margins or drop shadows)
 */
open class ToastView: UIView {

  let contentView: UIView

  init(contentView: UIView) {

    self.contentView = contentView
    super.init(frame: CGRect.zero)
    commonInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func commonInit() {
    layer.shadowColor = UIColor.gray.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowOpacity = 0.5
    addSubview(contentView)
    
    
    self.layoutMargins = UIEdgeInsets(top: (IS_IPHONEX ? -44 : -22), left: 0, bottom: 0, right: 0)

    // constraints
    contentView.translatesAutoresizingMaskIntoConstraints = false
    var constraints: [NSLayoutConstraint] = []
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[contentView]-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["contentView": contentView])
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[contentView]-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["contentView": contentView])
    addConstraints(constraints)
    
  }
}
