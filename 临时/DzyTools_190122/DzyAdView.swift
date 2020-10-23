//
//  DzyAdView.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/6/5.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

class DzyAdView: UIView {
    var times: TimeInterval = 3 {
        didSet {
            timer?.invalidate()
            timer = nil
            timerInitStep()
        }
    }
    
    fileprivate var urlArr:[String] = []
    
    fileprivate weak var scrollView:UIScrollView!
    
    fileprivate var page:UIPageControl!
    
    fileprivate var timer:Timer?
    
    weak var firstImgView: UIImageView?
    
    var ifBig: Bool
    
    var handler: ((Int)->())?
    
    init(frame: CGRect, urls:[String], ifBig: Bool = false) {
        urlArr = urls
        self.ifBig = ifBig
        super.init(frame: frame)
        scrollInitStep(frame: frame)
        pageInitStep()
        timerInitStep()
        basicStep()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if let imgView = tap.view as? UIImageView,
           let handler = handler
        {
            handler(imgView.tag)
        }
    }
    
    func scrollInitStep(frame: CGRect) {
        var lastFrame = frame
        lastFrame.size.height -= 20
        let scrollView = UIScrollView(frame: lastFrame)
        addSubview(scrollView)
        self.scrollView = scrollView
    }
    
    func pageInitStep() {
        page = UIPageControl(frame: CGRect(x: 0, y: dzy_h - 20, width: dzy_w, height: 20))
        page.backgroundColor = .white
        page.numberOfPages = urlArr.count
        page.currentPage = 0;
        page.pageIndicatorTintColor = .lightGray
        page.currentPageIndicatorTintColor = .red
        addSubview(page)
    }
    
    func timerInitStep() {
        if urlArr.count > 1 {
            timer = Timer(timeInterval: times, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
        }
    }
    
    func basicStep() {
        let count:CGFloat = CGFloat(urlArr.count)
        scrollView.delegate = self
        scrollView?.contentSize = CGSize(width: dzy_w * (count + 2.0), height: 0)
        scrollView?.backgroundColor = .white
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.setContentOffset(CGPoint(x: dzy_w, y: 0), animated: false)
        for a in 0...urlArr.count + 1 {
            let frame = CGRect(x: CGFloat(a) * dzy_w, y: 0, width: dzy_w, height: dzy_h)
            let imgView = UIImageView(frame: frame)
            imgView.isUserInteractionEnabled = true
            
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
            
            imgView.contentMode = .scaleAspectFit
            
            if ifBig {
                imgView.dzy_Img(urlStr, placeHolder: "nopic-big")
            }else{
                imgView.dzy_Img(urlStr, placeHolder: "nopic-logo")
            }
            
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
            page.currentPage = Int(x - 1)
        }
    }
    
    @objc func updateTimer() {
        let x = Int(scrollView.dzy_ofx / dzy_w)
        scrollView.setContentOffset(CGPoint(x: dzy_w * CGFloat(x + 1), y: 0), animated: true)
    }
}
