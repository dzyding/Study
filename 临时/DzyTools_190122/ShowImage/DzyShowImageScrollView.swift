//
//  DzyShowImageScrollView.swift
//  171026_Swift图片展示
//
//  Created by 森泓投资 on 2017/10/26.
//  Copyright © 2017年 EFOOD7. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate let Space: CGFloat = 10  //集合显示时的间隔

class DzyShowImageScrollView: UIScrollView {
    
    fileprivate weak var imgView: UIImageView?
    
    fileprivate var scale: CGFloat = 1.0    //缩放的比例
    
    var handler: (() -> ())?
    
    var url: String? {
        didSet {
            setUrl()
        }
    }
    
    var image: UIImage? {
        didSet {
            setImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func getImg(_ url: String, handler: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: url) else {return}
        KingfisherManager.shared.downloader.downloadImage(with: url, options: [.cacheOriginalImage]) { (img, error, _, _) in
            handler(img)
        }
    }
    
    fileprivate func setUrl() {
        guard let url = url else {return}
        getImg(url) { [weak self] (image) in
            if let image = image {
                self?.imgView?.image = image
                self?.updateContentSize(image)
            }
        }
    }
    
    fileprivate func setImage() {
        if let image = image {
            imgView?.image = image
            updateContentSize(image)
        }
    }
    
    func updateContentSize(_ image: UIImage) {
        let temp = image.size
        let width = temp.width > dzy_SW ? dzy_SW : temp.width
        let height = width / temp.width * temp.height
        contentSize = CGSize(width: width, height: height)
    }
    
    func initSubViews() {
        backgroundColor = .clear
        delegate = self
        minimumZoomScale = 1.0
        maximumZoomScale = 2.5
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        let imgView = UIImageView()
        imgView.frame = CGRect(x: 0, y: 0.0, width: dzy_SW, height: dzy_SH)
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        addSubview(imgView)
        self.imgView = imgView
        
        let once = UITapGestureRecognizer(target: self, action: #selector(onceTapAction(_:)))
        once.numberOfTapsRequired = 1
        imgView.addGestureRecognizer(once)
        
        let double = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        double.numberOfTapsRequired = 2
        imgView.addGestureRecognizer(double)
        
        once.require(toFail: double)
    }
    
    @objc func doubleTapAction(_ tap: UITapGestureRecognizer) {
        let endScale: CGFloat = scale < 2.5 ? 2.5 : 1
        setZoomScale(endScale, animated: true)
    }
    
    @objc func onceTapAction(_ tap: UITapGestureRecognizer) {
        handler?()
    }
}

extension DzyShowImageScrollView {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let imgView = imgView {
            let size = imgView.frame.size
            if (size.height < dzy_SH) {
                scrollView.contentInset = UIEdgeInsets(top: (dzy_SH - size.height) / 2.0, left: (dzy_SW - size.width) / 2.0, bottom: 0, right: 0)
            }else{
                scrollView.contentInset = .zero
            }
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scale = scale
    }
}
