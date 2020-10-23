//
//  Toaster.swift
//  ButteryToast
//
//  Created by creisterer on 11/3/15.
//  Copyright © 2015 Starry. All rights reserved.
//

import UIKit

/**
 Toaster manages a queue of Toasts and decides when they should be presented and dismissed.
 */
//swiftlint:disable line_length
open class Toaster {
    public static let sharedInstance = Toaster()

  public enum Style {
        case Success
        case Failure
        case Progress
   }
  /**
   The view controller that toasts should be presented from.
   This can be changed if there are separate sections (such as w/ navigation controllers) of the app, such as modal view controller presentations.
   Alternatively, each section could have its own Toaster.
  */
  open weak var defaultViewController: UIViewController? = nil {
    didSet {
      canOverrideActive = true
    }
  }

  // get view controller
  fileprivate func viewControllerToPresentIn() -> UIViewController? {
    if let defaultViewController = defaultViewController {
      return defaultViewController
    } else {
      return UIApplication.shared.keyWindow?.rootViewController
    }
  }

  // if default view controller changes, active message may be allowed to be replaced, in case
  // active message is no longer visible.
  fileprivate var canOverrideActive = false

  fileprivate(set) var messageStack: [Toast] = []

  /**
   Prepare a Toast to be presented to the user.
   - parameter toast: The toast, encapsulating a view
   - parameter priority: Low appends to bottom of stack, High appends to top,
     Immediate is presented even if another Toast on screen.
  */
  open func prepareToast(_ toast: Toast, withPriority priority: ToastPriority = ToastPriority.low) {
    toast.delegate = self
    // decide where to put message in stack
    switch priority {
    case .high, .immediate:
      messageStack.append(toast)
    case .low:
      messageStack.insert(toast, at: 0)
    }
    if priority == .immediate {
      dismissActiveMessage()  // dismissing message will also present next in line
    } else {
        // excluding immediate messages, message should only be presented if not already presenting a message
      if activeMessage == nil || canOverrideActive {
        canOverrideActive = false
        presentNextMessage()
      }
    }
  }

  // returns true if a message was dismissed, false if none found
  @discardableResult
  open func dismissActiveMessage() -> Bool {
    guard let activeMessage = activeMessage else {
      presentNextMessage()
      return false
    }
    activeMessage.dismiss()
    self.activeMessage = nil
    presentNextMessage()
    return true
  }

  // removes a specific toast from the stack or dismisses if active
  // returns true if cleared, false if not found.
  @discardableResult
  open func clearMessage(_ toast: Toast) -> Bool {
    if let activeMessage = activeMessage, activeMessage == toast {
      return dismissActiveMessage()
    } else {
      for (n, stackedToast) in messageStack.enumerated() where toast == stackedToast {
          messageStack.remove(at: n)
          return true
      }
      return false
    }
  }

  // returns true if a message was presented, false otherwise
  @discardableResult
  fileprivate func presentNextMessage() -> Bool {
    if let vc = viewControllerToPresentIn(), let _message = messageStack.popLast() {
      _message.displayInViewController(vc)
      activeMessage = _message
      return true
    } else {
      return false
    }
  }
  fileprivate var activeMessage: Toast?
}

extension Toaster: ToastDelegate {
  func toastDismissed(_ toast: Toast) {
    if toast == activeMessage {
      activeMessage = nil
      presentNextMessage()
    }
  }
}

public enum ToastPriority {
  case low
  case high
  case immediate
}
