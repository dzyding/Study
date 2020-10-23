//
//  DzyRefreshHeaderView.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2017/6/14.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

/** 刷新控件的状态 */
enum DzyRefreshState: Int {
    /** 还未初始化 */
    case none = 0
    /** 普通闲置状态 */
    case Idle
    /** 松开就可以进行刷新的状态 */
    case Pulling
    /** 正在刷新中的状态 */
    case Refreshing
    /** 即将刷新的状态 */
    case WillRefresh
    /** 所有数据加载完毕，没有更多的数据了 */
    case NoMoreData
}

fileprivate let RefreshH = 50

class DzyRefreshHeaderView: UIView {
    ///显示的箭头
    fileprivate var jiantou:UIImageView!
    ///圆圈
    fileprivate var circleLayer: CAShapeLayer?
    ///当前状态
    fileprivate var state: DzyRefreshState = .none {
        willSet{
            if state == newValue {return}
        }didSet {
            setState(old: oldValue)
        }
    }
    ///初始的Inset
    fileprivate var originInset: UIEdgeInsets = UIEdgeInsets.zero
    /** 拉拽的百分比 */
    fileprivate var pullingPercent: CGFloat = 0
    
    fileprivate weak var scrollView:UIScrollView?
    
    fileprivate var beginBlock:(()->())!

    init(_ beginBlock:@escaping (()->())) {
        self.beginBlock = beginBlock
        self.state = .Idle
        let frame = CGRect(x: 0, y: -RefreshH, width: Int(Screen_W), height: RefreshH)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func basicStep() {
        //这里可以添加一下是否需要在视图上面加个广告什么的
        setJianTou()
    }
    
    func setJianTou() {
        let imgView = UIImageView(frame: CGRect(x: (Screen_W - 14.0) / 2.0, y: dzy_h - 30, width: 14, height: 10))
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "refresh_jt")
        addSubview(imgView)
        self.jiantou = imgView
    }
    
//MARK: 画圆
    func drawRoundView(centerPoint:CGPoint, startAngle:CGFloat, endAngle:CGFloat, radius:CGFloat) {
        let path = UIBezierPath()
        path.addArc(withCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let arcLayer = CAShapeLayer()
        arcLayer.path = path.cgPath
        arcLayer.lineWidth = 2
        arcLayer.frame = dzy_rect(width: radius, height: radius)
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = Dzy_MainColor.cgColor
        layer.addSublayer(arcLayer)
        circleLayer = arcLayer
        beginCircle()
    }
    
    func beginCircle() {
        let bas = CABasicAnimation(keyPath: "strokeEnd")
        bas.duration = 2
        bas.fromValue = NSNumber(value: 0)
        bas.toValue   = NSNumber(value: 1)
        circleLayer?.add(bas, forKey: "key")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //这个必须在设置dataSource后面
        basicStep()
        removeObservers()
        guard let new = newSuperview else {
            return
        }
        if !new.isKind(of: UIScrollView.self) {return}
        
        // 记录UIScrollView
        if let scrollView = new as? UIScrollView {
            self.scrollView = scrollView
            // 设置永远支持垂直弹簧效果
            scrollView.alwaysBounceVertical = true
            // 记录UIScrollView最开始的contentInset
            originInset = scrollView.contentInset
            // 添加监听
            addObservers()
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
            //跳转到下一个控制器时，这个可能会变
            originInset = scrollView.contentInset
            //记录当前的
            let offsetY = scrollView.dzy_ofy
            //头部的控件刚好出现的offsetY
            let happenOffsetY = -(originInset.top)
            
            //如果是向上滚动到看不见头部控件，直接返回
            if offsetY > happenOffsetY {return}
            
            //普通 和 即将刷新 的临界点
            let normalPullingY = happenOffsetY - CGFloat(RefreshH)
            let pullPercent = (happenOffsetY - offsetY) / CGFloat(RefreshH)
            if scrollView.isDragging {
                pullingPercent = pullPercent
                if state == .Idle && offsetY < normalPullingY {
                    //转为即将刷新
                    state = .Pulling
                }else if (state == .Pulling) && (offsetY >= normalPullingY) {
                    //转为普通
                    state = .Idle
                }
            }else if state == .Pulling {
                //开始
                beginRefreshing()
            }else if pullPercent < 1 {
                self.pullingPercent = pullPercent
            }
        }
    }
    
//MARK: 设置状态
    func setState(old:DzyRefreshState) {
        if state == .Idle {
            if old != .none {
                JTAnimate()
            }
            if old != .Refreshing {return}
            //恢复inset offset
            UIView.animate(withDuration: 0.25, animations: { 
                self.scrollView?.contentInset = self.originInset
            }, completion: { (finished) in
                //还原动画百分比
                self.pullingPercent = 0.0;
                //移除圆圈
                self.circleLayer?.removeFromSuperlayer()
            })
        }else if state == .Refreshing {
            UIView.animate(withDuration: 0.25, animations: {
                // 增加滚动区域
                let top = self.originInset.top + CGFloat(RefreshH)
                self.scrollView?.dzy_inT = top
                // 设置滚动位置
                self.scrollView?.dzy_ofy = -top;
            }, completion: { (finished) in
                DispatchQueue.main.async(execute: {
                    //话圈
                    self.drawRoundView(centerPoint: self.jiantou.center, startAngle: 0, endAngle: CGFloat(2 * Double.pi), radius: 20)
                    //执行block
                    if let block = self.beginBlock {
                        block()
                    }
                })
            })
        }else if state == .Pulling {
            //箭头动画
            JTAnimate()
        }
    }
    
//MARK: 加入刷新状态
    func beginRefreshing() {
        UIView.animate(withDuration: 0.25) { 
            self.alpha = 1.0
        }
        pullingPercent = 1.0;
        state = .Refreshing
    }
    
//MARK: 结束刷新状态
    func endRefreshing() {
        state = .Idle
    }
    
//MARK: 箭头动画
    func JTAnimate() {
        UIView.animate(withDuration: 0.2) {
            self.jiantou.transform = self.jiantou.transform.rotated(by: CGFloat(Double.pi))
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
}
