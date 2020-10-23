//
//  CropVideoThumbnailView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/1.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol CropVideoThumbnailViewDelegate:NSObjectProtocol {
    func cutBarDidMovedToTime(_ time: CGFloat)
    func cutBarTouchesDidEnd()
}

class CropVideoThumbnailView: UIView {
    
    private var collectionview: UICollectionView!
    private var durationLB: UILabel!
    private var leftIV: UIImageView!
    private var rightIV: UIImageView!
    private var backgroundIV:UIImageView!
    private var selectedIV:UIImageView?
    
    private var imageviewWidth:CGFloat = 0
    
    private var imagesArr = [UIImage]()
    
    let itemWidth = (ScreenWidth - 5) / 6
    
    var avAsset: AVAsset?
    
    
    weak var delegate: CropVideoThumbnailViewDelegate?
    
    lazy var imageGenerator: AVAssetImageGenerator = {
        let imageGenerator = AVAssetImageGenerator(asset: self.avAsset!)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator.maximumSize = CGSize(width: 320, height: 320)
        return imageGenerator
        
    }()
    
    var cutInfo: CropVideoInfo!
    
    var lastOffsetX:CGFloat = 0
    
    init(frame: CGRect, cutinfo:CropVideoInfo) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ColorHexWithAlpha("#000000", 0.5)

        self.cutInfo = cutinfo
        setupCollectionView()
        setupSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCollectionView()
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        setupCollectionView()
        setupSubviews()
    }
    
    
    func setupCollectionView()
    {
        let followLayout = UICollectionViewFlowLayout()
        followLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        followLayout.minimumLineSpacing = 1
        followLayout.scrollDirection = .horizontal
        self.collectionview = UICollectionView(frame: CGRect(x: 0, y: self.na_height - itemWidth  - 9, width: ScreenWidth, height: itemWidth), collectionViewLayout: followLayout)
        self.collectionview.clipsToBounds = true
        self.collectionview.dataSource = self
        self.collectionview.delegate = self
        self.collectionview.bounces = false
        self.collectionview.backgroundColor = UIColor.clear
        self.collectionview.showsHorizontalScrollIndicator = false
        self.collectionview.contentInset = UIEdgeInsets(top: 0, left: itemWidth/2, bottom: 0, right: itemWidth/2)
        self.collectionview.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        self.addSubview(self.collectionview)
    }
    
    func setupSubviews(){
        
        imageviewWidth = itemWidth / 4
        
        durationLB = UILabel(frame: CGRect(x: imageviewWidth, y: 12, width: ScreenWidth-200, height: 12))
        durationLB.textColor = UIColor.white
        durationLB.font = ToolClass.CustomFont(12)
        self.addSubview(durationLB)
        
        leftIV = UIImageView(frame: CGRect(x: imageviewWidth, y: self.na_height - itemWidth - 9, width: imageviewWidth, height: itemWidth + 2))
        leftIV.image = UIImage(named: "video_clip")
        leftIV.isUserInteractionEnabled = true
        
        
        rightIV = UIImageView(frame: CGRect(x: ScreenWidth - imageviewWidth * 2, y: self.na_height - itemWidth - 9, width: imageviewWidth, height: itemWidth + 2))
        rightIV.image = UIImage(named: "video_clip")
        rightIV.isUserInteractionEnabled = true
        
        self.addSubview(leftIV)
        self.addSubview(rightIV)
        

        backgroundIV = UIImageView(frame: CGRect(x: leftIV.na_right, y: leftIV.na_top, width: rightIV.na_left - leftIV.na_right, height: itemWidth + 2))
        backgroundIV.image = UIImage(named: "video_line")
        
        self.addSubview(backgroundIV)
    }
    
    func loadThumbnailData()
    {
        
//        var maxleftMargin:CGFloat = 0
        
        var d:CGFloat = 0
        if cutInfo.duration! > cutInfo.maxDuration!
        {
            //视频长度超出了最大值
//            maxleftMargin = ScreenWidth - imageviewWidth * 2
            cutInfo.endTime = cutInfo.maxDuration!
            d = (cutInfo.maxDuration)! / 4.0
        }else{
            
//            maxleftMargin = cutInfo.duration! * (ScreenWidth - imageviewWidth * 2) / cutInfo.maxDuration!
            cutInfo.endTime = cutInfo.duration!
            
//            self.collectionview.na_width = maxleftMargin
            self.collectionview.isScrollEnabled = false
            
            d = cutInfo.duration! / 4.0
        }
//        rightIV.na_left = maxleftMargin
        
        durationLB.text = String(format: "裁剪长度：%.1fs 最短：%.0fs", cutInfo.endTime! - cutInfo.startTime!, cutInfo.minDuration!)
        backgroundIV.frame = CGRect(x: leftIV.na_right, y: leftIV.na_top, width: rightIV.na_left - leftIV.na_right, height: itemWidth + 2)
        
        
        var startTime = CMTime.zero
        var array = [NSValue]()
        var addTime = CMTime(value: 1000, timescale: 1000)
//        let d = (cutInfo.maxDuration)!/4.0
       
        let intd = d * 100
        let fd = Float(intd) / 100.0
        
        addTime = CMTimeMakeWithSeconds(Float64(fd), preferredTimescale: 1000)
        
        let endTime = CMTimeMakeWithSeconds(Float64(Float((cutInfo.duration)!)), preferredTimescale: 1000)
        
        while startTime <= endTime {
            array.append(NSValue(time: startTime))
            startTime = CMTimeAdd(startTime, addTime)
        }
        
        array[0] = NSValue(time: CMTimeMakeWithSeconds(0.1, preferredTimescale: 1000))
        
        var index = 0
        
        self.imageGenerator.generateCGImagesAsynchronously(forTimes: array) { (requestedTime, image, actualTime, result, error) in
            if result == AVAssetImageGenerator.Result.succeeded
            {
                let img = UIImage(cgImage: image!)
                DispatchQueue.main.async {
                    self.imagesArr.append(img)
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionview.insertItems(at: [indexPath])
                    index += 1
                }
            }
        }
    }
    
    func getOffsetTimeDuration() -> CGFloat{
        
        return abs((self.collectionview.contentOffset.x + self.collectionview.contentInset.left)  / (ScreenWidth - itemWidth) * cutInfo.maxDuration!)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        let adjustLeftRespondRect = leftIV.frame
        let adjustRightRespondRect = rightIV.frame
        
        if adjustLeftRespondRect.contains(point!)
        {
            selectedIV = leftIV
        }else if adjustRightRespondRect.contains(point!)
        {
            selectedIV = rightIV
        }else{
            selectedIV = nil
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if selectedIV == nil
        {
            return
        }
        
        let touch = touches.first
        let lp = touch?.location(in: self)
        let pp = touch?.previousLocation(in: self)
        
        let offset = (lp?.x)! - (pp?.x)!
        
        let time = offset / (ScreenWidth - itemWidth) * cutInfo.maxDuration!
        
        var maxDuration: CGFloat = 0

        if cutInfo.duration! > cutInfo.maxDuration!
        {
            maxDuration = cutInfo.maxDuration!
        }else{
            maxDuration = cutInfo.duration!
        }
        
        if selectedIV == leftIV
        {
            let left = cutInfo.startTime! + time

            if left > cutInfo.endTime! - maxDuration && left < cutInfo.endTime! - cutInfo.minDuration! && leftIV.na_left >= imageviewWidth
            {
                leftIV.na_left += offset
                
                leftIV.na_left = leftIV.na_left < imageviewWidth ? imageviewWidth : leftIV.na_left
                
                cutInfo.startTime = left < 0 ? 0 : left
                
                backgroundIV.frame = CGRect(x: leftIV.na_right, y: leftIV.na_top, width: rightIV.na_left - leftIV.na_right, height: itemWidth + 2)
                durationLB.text = String(format: "裁剪长度：%.1fs 最短：%.0fs", cutInfo.endTime! - cutInfo.startTime!, cutInfo.minDuration!)
                
                self.delegate?.cutBarDidMovedToTime(left)
            }
        }else if selectedIV == rightIV{
            let right = cutInfo.endTime! + time
            
            if cutInfo.startTime! + cutInfo.minDuration! < right && right < cutInfo.startTime! + maxDuration && rightIV.na_left <= ScreenWidth - imageviewWidth * 2
            {
                cutInfo.endTime = right > cutInfo.duration! ? cutInfo.duration! :  right
                
                rightIV.na_left += offset
                rightIV.na_left = rightIV.na_left > ScreenWidth - imageviewWidth * 2 ? ScreenWidth - imageviewWidth * 2 : rightIV.na_left
                
                 backgroundIV.frame = CGRect(x: leftIV.na_right, y: leftIV.na_top, width: rightIV.na_left - leftIV.na_right, height: itemWidth + 2)
                durationLB.text = String(format: "裁剪长度：%.1fs 最短：%.0fs", cutInfo.endTime! - cutInfo.startTime!, cutInfo.minDuration!)
                
                self.delegate?.cutBarDidMovedToTime(right)

            }
        }
        
        print("startTime",cutInfo.startTime!)
        print("endTime",cutInfo.endTime!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        selectedIV = nil
        self.delegate?.cutBarTouchesDidEnd()
    }
}
extension CropVideoThumbnailView: UICollectionViewDataSource,UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        let image = imagesArr[indexPath.row]
        
        let iv = UIImageView(image: image)
        iv.frame = cell.contentView.bounds
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        cell.contentView.addSubview(iv)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let curent = getOffsetTimeDuration()
        cutInfo.startTime! += (curent - lastOffsetX)
        cutInfo.endTime! += (curent - lastOffsetX)
        lastOffsetX = curent
        durationLB.text = String(format: "裁剪长度：%.1fs 最短：%.0fs", cutInfo.endTime! - cutInfo.startTime!, cutInfo.minDuration!)
        self.delegate?.cutBarDidMovedToTime(cutInfo.startTime!)
        self.delegate?.cutBarTouchesDidEnd()

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            let curent = getOffsetTimeDuration()
            cutInfo.startTime! += (curent - lastOffsetX)
            cutInfo.endTime! += (curent - lastOffsetX)
            lastOffsetX = curent
            durationLB.text = String(format: "裁剪长度：%.1fs 最短：%.0fs", cutInfo.endTime! - cutInfo.startTime!, cutInfo.minDuration!)
            self.delegate?.cutBarDidMovedToTime(cutInfo.startTime!)
            self.delegate?.cutBarTouchesDidEnd()

        }
    }
}

