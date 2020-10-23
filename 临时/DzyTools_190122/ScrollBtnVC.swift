//
//  ScrollBtnVC.swift
//  HousingMarket
//
//  Created by edz on 2018/11/27.
//  Copyright © 2018年 远坂凛. All rights reserved.
//

import UIKit

enum ScrollBtnPlaceType {
    case topTop     // 直接到顶
    case topCustom(top: CGFloat)  // 顶部到自定义的位置
}

class ScrollBtnVC: BaseVC {
    
    var titles = [String]()
    
    var btnsView: ScrollBtnView?
    
    var scrollView: UIScrollView?
    
//    var vcs: [UIViewController] = []
    
    var type: ScrollBtnPlaceType
    
    /**
     各种默认属性
     */
    ///按钮滚动视图的frame
    var btnsFrame: CGRect {
        return CGRect(x: 0, y: 0, width: ScreenWidth, height: UI_H(41))
    }
    
    init(_ titles: [String], type: ScrollBtnPlaceType = .topTop) {
        self.titles = titles
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
        setScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func btnsViewClick(_ index: Int) {
        let x = CGFloat(index) * ScreenWidth
        scrollView?.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    fileprivate func initBtnsView() {
        let btnsView = ScrollBtnView(btns: titles, frame: btnsFrame, font: dzy_Font(13), normalColor: RGB(r: 51.0, g: 51.0, b: 51.0), selectedColor: MainColor, type: .scale_widthFit) { [unowned self] (index) in
            self.btnsViewClick(index)
        }
        btnsView.selectedFont = dzy_Font(15)
        btnsView.setSelectBtn(x: 0)
        btnsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnsView)
        self.btnsView = btnsView
        
        
        NSLayoutConstraint.activate([
            btnsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            btnsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            btnsView.heightAnchor.constraint(equalToConstant: UI_H(41))
            ])
        
        if case .topCustom(let top) = type {
            btnsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: top).isActive = true
        }else {
            btnsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
        
    }
    
    fileprivate func setScrollView() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: ScreenWidth * CGFloat(titles.count), height: 1)
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        self.scrollView = scrollView
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: btnsView!.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    func updateVCs() {
        let vcs = getVCs()
        (0..<vcs.count).forEach { (index) in
            let vc = vcs[index]
            addChild(vc)
            guard let view = vc.view else {return}
            guard let scrollView = scrollView else {return}
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(index) * ScreenWidth),
                view.widthAnchor.constraint(equalToConstant: ScreenWidth),
                view.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
                view.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor)
                ])
        }
    }
    
    //    MARK: - 留给子类继承
    func getVCs() -> [UIViewController] {return []}
}

extension ScrollBtnVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = Int(x / ScreenWidth)
        btnsView?.setSelectBtn(x: page)
    }
}
