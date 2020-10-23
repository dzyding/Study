//
//  LongImageVC.swift
//  PPBody
//
//  Created by edz on 2019/5/29.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit
import Kingfisher

class LongImageVC: BaseVC {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private weak var imgView: UIImageView?
    
    let imgName: String
    
    init(_ imgName: String) {
        self.imgName = imgName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = shareItem
        setUI()
    }
    
    func setUI() {
        if let image = UIImage(named: imgName) {
            updateUI(image)
        }else {
            guard let url = URL(string: imgName) else {return}
            KingfisherManager
                .shared
                .downloader
                .downloadImage(with: url,
                               options: [.cacheOriginalImage])
                { [weak self] (result) in
                switch result {
                case .success(let value):
                    self?.updateUI(value.image)
                case .failure(let error):
                    dzy_log(error)
                }
            }
        }
    }
    
    private func updateUI(_ image: UIImage) {
        let height = ScreenWidth / image.size.width * image.size.height
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: height)
        scrollView.contentSize = imageView.frame.size
        scrollView.addSubview(imageView)
        self.imgView = imageView
    }
    
    @objc private func shareAction(_ btn: UIButton) {
        guard let image = imgView?.image else {
            ToolClass.showToast("图片加载中，请稍后", .Failure)
            return
        }
        let sview = SharePlatformView.instanceFromNib()
        sview.frame = ScreenBounds
        sview.image = image
        sview.initUI(.longImage)
        UIApplication.shared.keyWindow?.addSubview(sview)
    }
    
    //    MARK: - 懒加载
    private lazy var shareItem: UIBarButtonItem = {
        let btn = DzySafeBtn(type: .custom)
        btn.enabledTime = 1
        btn.setImage(UIImage(named: "goods_share"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        btn.addTarget(self,
                      action: #selector(shareAction(_:)),
                      for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
}
