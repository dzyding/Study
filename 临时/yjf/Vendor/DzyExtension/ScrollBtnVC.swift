//
//  ScrollBtnVC.swift
//  HousingMarket
//
//  Created by edz on 2018/11/27.
//  Copyright © 2018年 远坂凛. All rights reserved.
//

import UIKit

enum ScrollBtnPlaceType {
    case naviBar(CGSize)    // 放到NaviBar中
    case topTop     // 直接到顶
    case topCustom  // 顶部到自定义的位置
}

class ScrollBtnVC: BaseVC {
    /// 供子类继承，以提供 titles
    var titles: [String] {
        return []
    }
    /// 按钮的类型
    var btnsViewType: ScrollBtnType {
        return .scale_custom(CGSize(width: 23, height: 2))
    }
    /// 到顶部的距离
    var btnsViewTopHeight: CGFloat {
        return 0
    }
    /// 按钮的高度
    var btnsViewHeight: CGFloat {
        return UI_H(41)
    }
    /// 底部的距离
    var bottomHeight: CGFloat {
        return 0
    }
    var normalColor: UIColor {
        return dzy_HexColor(0x646464)
    }
    
    var selectedColor: UIColor {
        return dzy_HexColor(0x262626)
    }
    
    var normalFont: UIFont {
        return dzy_Font(14)
    }
    
    var selectedFont: UIFont {
        return dzy_FontBlod(17)
    }
    /// 左间距
    var leftPadding: CGFloat {
        return 0
    }
    /// 右间距
    var rightPadding: CGFloat {
        return 0
    }
    /// 线离底边的距离
    var lineToBottom: CGFloat {
        return 5
    }
    /// btnsView 下面是否包含分割线
    var isPaddingLine: Bool {
        return false
    }
    /// 分割线的颜色
    var paddingLineColor: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1)
    }
    /// 初始展示的vc
    var firstShowIndex: Int = 0
    
    private var btnsView: ScrollBtnView?
    
    private var scrollView: UIScrollView?
    
    private let type: ScrollBtnPlaceType
    
    /**
     各种默认属性
     */
    ///按钮滚动视图的frame
    var btnsFrame: CGRect {
        return CGRect(
            x: leftPadding,
            y: 0,
            width: ScreenWidth - leftPadding - rightPadding,
            height: btnsViewHeight
        )
    }
    
    init(_ type: ScrollBtnPlaceType = .topTop) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initBtnsView()
        initPaddingLine()
        setScrollView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstShowIndex != 0 {
            btnsView?.updateSelectedBtn(firstShowIndex)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// 点击切换界面
    func updateSelectedBtn(_ index: Int) {
        btnsView?.updateSelectedBtn(index)
    }
    
    /// 选择按钮时的响应事件 可供子类继承，添加逻辑
    func btnsViewDidClick(_ index: Int) {
        let x = CGFloat(index) * ScreenWidth
        scrollView?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    //    MARK: - 初始化按钮视图
    fileprivate func initBtnsView() {
        let btnsView = ScrollBtnView(btnsViewType, frame: btnsFrame) { [unowned self] (index) in
                self.btnsViewDidClick(index)
        }
        btnsView.font = normalFont
        btnsView.selectedFont = selectedFont
        btnsView.normalColor = normalColor
        btnsView.selectedColor = selectedColor
        btnsView.lineColor = MainColor
        btnsView.lineToBottom = lineToBottom
        btnsView.selectedIndex = 0
        btnsView.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case .naviBar(let size):
            btnsView.intrinsicSize = size
            btnsView.invalidateIntrinsicContentSize()
            navigationItem.titleView = btnsView
            self.btnsView = btnsView
        default:
            view.addSubview(btnsView)
            self.btnsView = btnsView
            
            NSLayoutConstraint.activate([
                btnsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftPadding),
                btnsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -rightPadding),
                btnsView.heightAnchor.constraint(equalToConstant: btnsViewHeight)
                ])
            
            if case .topCustom = type {
                btnsView.topAnchor.constraint(
                    equalTo: view.dzyLayout.topAnchor,
                    constant: btnsViewTopHeight
                    ).isActive = true
            }else {
                btnsView.topAnchor.constraint(
                    equalTo: view.dzyLayout.topAnchor
                    ).isActive = true
            }
        }
    }
    
    //    MARK: - 创建主 ScrollView
    fileprivate func setScrollView() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(scrollView)
        self.scrollView = scrollView
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.dzyLayout.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.dzyLayout.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.dzyLayout.bottomAnchor, constant: -bottomHeight)
            ])
        switch type {
        case .naviBar:
            scrollView.topAnchor
                .constraint(equalTo: view.dzyLayout.topAnchor)
                .isActive = true
        default:
            scrollView.topAnchor
                .constraint(equalTo: btnsView!.bottomAnchor)
                .isActive = true
        }
    }
    
    //    MARK: - 分割线
    func initPaddingLine() {
        guard isPaddingLine, let btnsView = btnsView else {return}
        let frame = CGRect(
            x: btnsView.frame.minX,
            y: btnsView.frame.maxY - 1,
            width: btnsView.frame.size.width,
            height: 1
        )
        let line = UIView(frame: frame)
        line.backgroundColor = paddingLineColor
        view.addSubview(line)
    }
    
    //    MARK: - 供子类使用更新视图
    func updateVCs() {
        btnsView?.btns = titles
        btnsView?.updateUI()
        scrollView?.contentSize = CGSize(width: ScreenWidth * CGFloat(titles.count), height: 1)
        let vcs = getVCs()
        (0..<vcs.count).forEach { (index) in
            let vc = vcs[index]
            addChild(vc)
            guard let view = vc.view else {return}
            guard let scrollView = scrollView else {return}
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(
                    equalTo: scrollView.leadingAnchor,
                    constant: CGFloat(index) * ScreenWidth
                ),
                view.widthAnchor.constraint(equalToConstant: ScreenWidth),
                view.topAnchor.constraint(equalTo: scrollView.dzyLayout.topAnchor),
                view.bottomAnchor.constraint(equalTo: scrollView.dzyLayout.bottomAnchor)
                ])
        }
    }
    
//    MARK: - 清除子视图
    func clearVCs() {
        btnsView?.selectedIndex = 0
        scrollView?.contentOffset = CGPoint(x: 0, y: 0)
        guard let scrollView = scrollView else {return}
        while !children.isEmpty {
            children.last?.removeFromParent()
        }
        while !scrollView.subviews.isEmpty {
            scrollView.subviews.last?.removeFromSuperview()
        }
    }
    
    //    MARK: - 留给子类继承
    func getVCs() -> [UIViewController] {return []}
}

extension ScrollBtnVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = Int(x / ScreenWidth)
        btnsView?.updateSelectedBtn(page)
    }
}
