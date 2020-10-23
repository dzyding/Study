//
//  Toast.swift
//  ButteryToast
//
//  Created by creisterer on 11/3/15.
//  Copyright © 2015 Starry. All rights reserved.
//

import Foundation
import UIKit

/**
 A toast contains a view for presentation by a Toaster.
 Toasts are unique - even two Toasts containing the same view are still different Toasts.
 This allows for managing toasts in a queue and determining if they have been presented yet.
 */
open class Toast: Equatable {

  fileprivate let view: UIView
  fileprivate let dismissAfter: TimeInterval?

  fileprivate let height: CGFloat?

  /**
   Initializes the `Toast` instance with the specified view.
   - parameter dismissAfter: If set, the time interval after which a Toast will auto-dismiss without user interaction. If unset, a Toast will persist until dismissed.
   - parameter height: If set, the height of the toast, enforced by AutoLayout. If unset, the height will be determined soley from the intrinsic content size of the view passed to the Toast.
  */
  public init(view: UIView, dismissAfter: TimeInterval? = nil, height: CGFloat?=nil) {
    self.view = view
    self.dismissAfter = dismissAfter
    self.height = height
  }

  fileprivate var messageView: ToastView?
  weak var delegate: ToastDelegate?  // messenger that presented message

  internal func displayInViewController(_ viewController: UIViewController) {

    let alertView = ToastView(contentView: view)
    alertView.translatesAutoresizingMaskIntoConstraints = false

    var constraints: [NSLayoutConstraint] = []
    let parentView: UIView

    // place the alert in navigation bar if possible
    if let navigationController = viewController.navigationController {
      parentView = navigationController.view
      navigationController.view.insertSubview(alertView, aboveSubview: navigationController.navigationBar)

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[alertView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["alertView": alertView])

      if navigationController.navigationBar.isHidden {
        constraints += NSLayoutConstraint.constraints(withVisualFormat : "V:|-0-[alertView]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["alertView": alertView])
      } else {
        constraints += NSLayoutConstraint.constraints(withVisualFormat : "V:|-0-[alertView]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["alertView": alertView])
      }
    } else {
      // no navigation bar, just place on view controller at top
      parentView = viewController.view
      viewController.view.addSubview(alertView)

        constraints += NSLayoutConstraint.constraints(withVisualFormat : "H:|-0-[alertView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["alertView": alertView])

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[alertView]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["alertView": alertView])
    }
    if let height = height {
      constraints.append(NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    }

    parentView.addConstraints(constraints)

    alertView.setNeedsLayout()
    alertView.layoutIfNeeded()

    alertView.alpha = 0.0
    alertView.transform = CGAffineTransform(translationX: 0.0, y: -alertView.bounds.height)
    UIView.animate(withDuration: 0.25, animations: {
      alertView.alpha = 1.0
      alertView.transform = CGAffineTransform.identity
    }) 

    let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    alertView.addGestureRecognizer(tapGR)

    // setup delayed dismissal
    if let dismissAfter = dismissAfter {
      let delay = Int64(Double(dismissAfter) * Double(NSEC_PER_SEC))
      let after = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: after) { [weak self] in
        self?.dismiss()
      }
    }

    messageView = alertView

  }

  @objc func handleTap(_ tapGesture: UITapGestureRecognizer) {
    dismiss()
  }

  func dismiss() {
    if let messageView = messageView {
      UIView.animate(withDuration: 0.25, animations: {
        messageView.alpha = 0.0
        messageView.transform = CGAffineTransform(translationX: 0.0, y: -messageView.bounds.height)
        }, completion: { success in
          messageView.removeFromSuperview()
          self.delegate?.toastDismissed(self)
      })
    } else {
      delegate?.toastDismissed(self)
    }
  }
}

public func ==(lhs: Toast, rhs: Toast) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}


protocol ToastDelegate: class {
  
  func toastDismissed(_ toast: Toast)
  
}
