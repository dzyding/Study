//
//  SimpleRefreshView.swift
//  Demo
//
//  Created by MORITANAOKI on 2015/12/31.
//  Copyright © 2015年 molabo. All rights reserved.
//
import Foundation
import UIKit
import SpinKit

public let DEFAULT_ACTIVITY_INDICATOR_VIEW_STYLE: UIActivityIndicatorView.Style = .gray
public let DEFAULT_PULLING_IMAGE: UIImage? = {
    if let imagePath = Bundle(for: SimpleRefreshView.self).path(forResource: "pull", ofType: "png") {
        return UIImage(named: "refresh")
    }
    return nil
}()

open class SimpleRefreshView: UIView, SwfitRefresherEventReceivable {
    fileprivate weak var spinkit: RTSpinKitView!
    fileprivate weak var pullingImageView: UIImageView!
    
    fileprivate var activityIndicatorViewStyle = DEFAULT_ACTIVITY_INDICATOR_VIEW_STYLE
    fileprivate var pullingImage: UIImage?
    
    public convenience init(activityIndicatorViewStyle: UIActivityIndicatorView.Style, pullingImage: UIImage? = DEFAULT_PULLING_IMAGE) {
        self.init(frame: CGRect.zero)
        self.activityIndicatorViewStyle = activityIndicatorViewStyle
        self.pullingImage = pullingImage
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        let spinkit = RTSpinKitView(style: .styleThreeBounce, color: UIColor.gray)
        addSubview(spinkit!)
        spinkit?.isHidden = true
        spinkit!.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(
            [
                NSLayoutConstraint(item: spinkit!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: spinkit!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ]
        )
        self.spinkit = spinkit
        
        let pView = UIImageView(frame: CGRect.zero)
        pView.contentMode = .scaleAspectFit
        pView.image = pullingImage
        addSubview(pView)
        pView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(
            [
                NSLayoutConstraint(item: pView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: pView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
//                NSLayoutConstraint(item: pView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 106.0),
//                NSLayoutConstraint(item: pView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0),
            ]
        )
        
        self.pullingImageView = pView
    }
    
open func didReceiveEvent(_ event: SwiftRefresherEvent) {
    switch event {
    case .pull:
        pullingImageView.isHidden = false
    case .startRefreshing:
        pullingImageView.isHidden = true
        self.spinkit.startAnimating()
        self.spinkit.isHidden = false
    case .endRefreshing:
        self.spinkit.stopAnimating()
        self.spinkit.isHidden = true
    case .recoveredToInitialState:
        break
    }
}
}
