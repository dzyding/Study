//
//  DzyShowImageView.swift
//  171026_Swift图片展示
//
//  Created by 森泓投资 on 2017/10/26.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit

enum DzyShowImageType {
    case one(String)                //单个 url 图片
    case image(UIImage)             //单个图片
    case updateOne(UIImage, ()->())        //附加更换按钮的单个图片
    case more([String], Int)        //图片集合  Int为初始位置
}

fileprivate let Space: CGFloat = 10  //集合显示时的间隔

class DzyShowImageView: UIView {
    var type: DzyShowImageType
    
    fileprivate weak var collectionView: UICollectionView?  //多个图片时使用
    
    fileprivate var data: [String] = []    //针对collectionView
    
    fileprivate var updateHandler:(()->())?
    
    fileprivate lazy var bgView: UIView = { //背景图
        let v = UIView()
        v.frame = UIScreen.main.bounds
        v.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 0.6)
        return v
    }()
    
    init(_ type: DzyShowImageType) {
        self.type = type
        super.init(frame: UIScreen.main.bounds)
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        backgroundColor = .clear
        switch type {
        case .one, .updateOne, .image:
            setScrollView()
        case .more(let arr, let index):
            data = arr
            setCollectionView()
            
            let indexPath = IndexPath(item: index, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    //    MARK: 显示
    func show(_ view: UIView? = nil) {
        if let view = view {
            view.addSubview(bgView)
            view.addSubview(self)
        }else {
            UIApplication.shared.keyWindow?.addSubview(bgView)
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        
    }
    
    //    MARK: 隐藏
    @objc func hidden() {
        bgView.removeFromSuperview()
        removeFromSuperview()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let _ = newSuperview {
            bgView.alpha = 0
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 0.25) {
            self.bgView.alpha = 1
        }
    }
    
    @objc func updateAction() {
        updateHandler?()
        hidden()
    }
    
    deinit {
        dzy_log("销毁")
    }
}

extension DzyShowImageView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDzyShowImageCell, for: indexPath) as! DzyShowImageCell
        cell.url = data[indexPath.row]
        cell.handler = { [unowned self] in
            self.hidden()
        }
        return cell
    }
}

//MARK: - UI
extension DzyShowImageView {
    func setScrollView() {
        let scrollView = DzyShowImageScrollView(frame: bounds)
        scrollView.handler = { [unowned self] in
            self.hidden()
        }
        addSubview(scrollView)
        
        switch type {
        case .one(let url):
            scrollView.url = url
        case .updateOne(let image, let block):
            bgView.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1)
            scrollView.image = image
            // 添加更换按钮
            setUpdateBtn()
            updateHandler = block
        case .image(let image):
            bgView.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1)
            scrollView.image = image
        default:
            break
        }
    }
    
    func setCollectionView() {
        let frame = CGRect(x: -Space, y: 0, width: dzy_SW + Space * 2.0, height: dzy_SH)
        let layOut = UICollectionViewFlowLayout()
        layOut.itemSize = frame.size
        layOut.scrollDirection = .horizontal
        layOut.minimumInteritemSpacing = 0
        layOut.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layOut)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        addSubview(collectionView)
        self.collectionView = collectionView
        
        collectionView.register(DzyShowImageCell.self, forCellWithReuseIdentifier: kDzyShowImageCell)
    }
    
    func setCloseBtn() {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "showImage_close"), for: .normal)
        btn.frame = CGRect(x: dzy_SW - 40, y: 10, width: 30, height: 30)
        addSubview(btn)
        
        btn.addTarget(self, action: #selector(hidden), for: .touchUpInside)
    }
    
    func setUpdateBtn() {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: (dzy_SW - 120.0)/2.0, y: dzy_SH - 130, width: 120, height: 35)
        btn.setTitle("更换", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(updateAction), for: .touchUpInside)
        addSubview(btn)
    }
}
