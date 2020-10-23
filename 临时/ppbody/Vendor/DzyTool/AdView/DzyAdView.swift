//
//  DzyAdView.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/6/5.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

enum AdPageType {
    case rect   //矩形
    case num    //数字
}

class DzyAdView: UIView {
    
    var times: TimeInterval = 3 {
        didSet {
            timer?.invalidate()
            timer = nil
            timerInitStep()
        }
    }
    
    fileprivate var urlArr:[String] = []
    
    fileprivate weak var scrollView: UIScrollView?
    
    fileprivate let pageType: AdPageType
    
    fileprivate weak var page: AdPageProtocol?
    
    fileprivate var timer: Timer?
    
    weak var firstImgView: UIImageView?
    
    var handler: ((Int)->())?
    
    init(_ frame: CGRect, pageType: AdPageType) {
        self.pageType = pageType
        super.init(frame: frame)
        scrollInitStep()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(_ urls: [String], isTimer: Bool = true) {
        self.urlArr = urls
        pageInitStep()
        if isTimer {
            timerInitStep()
        }
        basicStep()
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if let imgView = tap.view as? UIImageView,
           let handler = handler
        {
            handler(imgView.tag)
        }
    }
    
    private func scrollInitStep() {
        let scrollView = UIScrollView(frame: bounds)
        addSubview(scrollView)
        self.scrollView = scrollView
    }
    
    private func pageInitStep() {
        guard urlArr.count > 1,
            let scrollFrame = scrollView?.frame else
        {return}
        switch pageType {
        case .rect:
            let width:CGFloat = (8.0 + 6.0) * CGFloat(urlArr.count) - 6.0
            let frame = CGRect(
                x: scrollFrame.width - 18.0 - width,
                y: scrollFrame.height - 8.0,
                width: width,
                height: 2
            )
            let page = RectPageController(frame: frame)
            page.updateUI(urlArr.count)
            addSubview(page)
            self.page = page
        case .num:
            let frame = CGRect(
                x: scrollFrame.width - 40.0 - 16.0,
                y: scrollFrame.height - 22.0 - 10.0,
                width: 40.0,
                height: 22.0
            )
            let page = NumPageController(frame: frame)
            page.updateUI(urlArr.count)
            addSubview(page)
            self.page = page
        }
    }
    
    private func timerInitStep() {
        if urlArr.count > 1 {
            timer = Timer(
                timeInterval: times,
                target: self,
                selector: #selector(updateTimer),
                userInfo: nil,
                repeats: true
            )
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    private func basicStep() {
        let count:CGFloat = CGFloat(urlArr.count)
        scrollView?.delegate = self
        scrollView?.contentSize = CGSize(width: dzy_w * (count + 2.0), height: 0)
        scrollView?.backgroundColor = BackgroundColor
        scrollView?.isPagingEnabled = true
        scrollView?.bounces = false
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.setContentOffset(CGPoint(x: dzy_w, y: 0), animated: false)
        for a in 0...urlArr.count + 1 {
            let frame = CGRect(x: CGFloat(a) * dzy_w, y: 0, width: dzy_w, height: dzy_h)
            let imgView = UIImageView(frame: frame)
            imgView.contentMode = .scaleAspectFill
            imgView.isUserInteractionEnabled = true
            imgView.layer.masksToBounds = true
            imgView.backgroundColor = .clear
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            imgView.addGestureRecognizer(tap)
            var urlStr = ""
            if a == 0 {
                urlStr = urlArr.last ?? ""
                imgView.tag = urlArr.count - 1
            }else if a == urlArr.count + 1 {
                urlStr = urlArr.first ?? ""
                imgView.tag = 0
            }else {
                urlStr = urlArr[a - 1]
                imgView.tag = a - 1
            }
            imgView.setCoverImageUrl(urlStr)
            scrollView?.addSubview(imgView)
            if a == 1 {
                firstImgView = imgView
            }
        }
    }
    
    func timerStop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        dzy_log("销毁")
    }
}

extension DzyAdView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.dzy_ofx / dzy_w
        if x == 0 {
            scrollView.setContentOffset(CGPoint(x: dzy_w * CGFloat(urlArr.count), y: 0), animated: false)
        }else if x == CGFloat(urlArr.count + 1) {
            scrollView.setContentOffset(CGPoint(x: dzy_w, y: 0), animated: false)
        }else {
            page?.updatePage(Int(x - 1))
        }
    }
    
    @objc func updateTimer() {
        let offsetX = scrollView?.dzy_ofx ?? 0
        let x = Int(offsetX / dzy_w)
        scrollView?.setContentOffset(CGPoint(
            x: dzy_w * CGFloat(x + 1),
            y: 0
        ), animated: true)
    }
}
