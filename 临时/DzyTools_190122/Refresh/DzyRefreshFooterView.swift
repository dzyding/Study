//
//  DzyRefreshFooterView.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/6/15.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

class DzyRefreshFooterView: UIView {
    ///当前状态
    fileprivate var state: DzyRefreshState = .none {
        willSet{
            if state == newValue {return}
        }didSet {
            setState(old: oldValue)
        }
    }
    //确保到底部以后只刷新一次
    fileprivate var refresh = false
    
    fileprivate weak var scrollView: UIScrollView?
    
    fileprivate var beginBlock: ()->()
    
    //其实现在这样已经没必要写成一个view了，不过牵扯到太多的老代码，就还是用view吧。
    init(_ beginBlock: @escaping (()->())) {
        self.beginBlock = beginBlock
        self.state = .Idle
        let frame = CGRect(x: 0, y: 0, width: Int(Screen_W), height: 1)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        removeObservers()
        guard let new = newSuperview else {return}
        if !new.isKind(of: UIScrollView.self) {return}
        
        // 记录UIScrollView
        if let scrollView = new as? UIScrollView {
            self.scrollView = scrollView
            // 设置永远支持垂直弹簧效果
            scrollView.alwaysBounceVertical = true
            // 添加监听
            addObservers()
        }
    }
    
    //MARK: 设置状态
    func setState(old: DzyRefreshState) {
        if state == .Idle {
            if old != .Refreshing {return}
        }else if state == .Refreshing {
            beginBlock()
        }
    }

    
//MARK: 添加观察者
    func addObservers() {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
    }
    
//MARK: 移除观察者
    func removeObservers() {
        superview?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = scrollView else {return}
        if keyPath == "contentOffset" {
            //在刷新的话返回
            if self.state == .Refreshing {return}
            //如果内容小于scrollView的高度(相当于已经加载完成的)
            if scrollView.dzy_cSizeH < scrollView.dzy_h {return}
            //刚刷新过，就直接退出
            if refresh {return}
            //记录当前的
            let offsetY = scrollView.dzy_ofy
            //刚好到底部的offsetY
            let happenOffsetY = getHappenOffsetY()
            
            if state == .Idle && offsetY >= (happenOffsetY - 10) {
                //刷新
                refresh = true
                state = .Refreshing
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.refresh = false
                }
            }
        }
    }
    
    func getHappenOffsetY() -> CGFloat {
        guard let scrollView = scrollView else {
            return 0
        }
        return scrollView.dzy_cSizeH - scrollView.dzy_h - scrollView.dzy_inT - scrollView.dzy_inB
    }
    
    //MARK: 结束刷新状态
    func endRefreshing() {
        if state == .Refreshing {
            state = .Idle
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
}
