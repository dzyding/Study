//
//  TimelineView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/28.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol TimelineViewDelegate:NSObjectProtocol {
    /**
     回调拖动的item对象（在手势结束时发生）
     
     @param item timeline对象
     */
    func timelineDraggingTimelineItem(_ item: TimelineItem)
    /**
     回调timeline开始被手动滑动
     */
    func timelineBeginDragging()
    
    func timelineDraggingAtTime(_ time: CGFloat)
    
    func timelineEndDraggingAndDecelerate(_ time: CGFloat)
    
    func timelineCurrentTime(_ time: CGFloat, duration: CGFloat)
}

enum kVideoDirection {
    case Unkown
    case Portrait
    case PortraitUpsideDown
    case LandscapeRight
    case LandscapeLeft
}

class TimelineView: UIView {
   
    var leftPinchImageName:String?
    var rightPinchImageName:String?
    var pinchBgImageName: String?
    var indicatorColor: UIColor?
    var pinchBgColor: UIColor?
    var actualDuration: CGFloat = 0
    var coverImage: UIImage?
    
    
    private var itemWidth:CGFloat = 0
    private var itemHeight:CGFloat = 0
    private var totalItemsWidth:CGFloat!
    private var collectionView: UICollectionView!
    
    private var photoItems = [UIImage]()
    private var videoDuration: CGFloat = 0
    private var indicator: UIView!
    private var leftPinchView: UIImageView!
    private var rightPinchView: UIImageView!
    private var pinchBackgroudView: UIImageView!
    private var singleItemDuration: CGFloat?
    private var photoCounts = [NSValue]()
    private var photosPersegment: Int = 0
    private var leftPinchTime:CGFloat?
    private var rightPinchTime: CGFloat?
    private var timelinePercentItems = [[TimelinePercent]]()
    private var timelineItems = [TimelineItem]()
    private var timelinePercentFilterItems = [[TimelinePercent]]()
    private var timelineFilterItems = [TimelineFilterItem]()
    private var rotateDict:[String:Any]?
    private var durationDict:[String:Any]?
    private var imageGenerator:AVAssetImageGenerator?
    private var segment:CGFloat?
    
    private var isDragging = false
    private var isDecelerate = false
    private var leftPinchWidth: CGFloat = 0
    private var rightPinchWidth: CGFloat = 0
    private var selectedPinchImageView: UIImageView?
    private var scheduleTimer: Timer?
    private var currentItem: TimelineItem?
    private var generator: AssetImageGenerator?
    
    weak var delegate:TimelineViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.itemWidth = frame.size.height
        self.itemHeight = frame.size.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil{
            self.imageGenerator?.cancelAllCGImageGeneration()
            generator?.cancel()
        }
    }
    
    /**
     获取当前时间指针所指向的时间
     
     @return 时间
     */
    func getCurrentTime()->CGFloat
    {
        var offsetPoint = self.indicator.center.x + self.collectionView.contentOffset.x
        if offsetPoint < 0
        {
            offsetPoint = 0
        }else if offsetPoint > self.totalItemsWidth
        {
            offsetPoint = self.totalItemsWidth
        }
        
        let timeFromOffset = self.timeWithOffset(offsetPoint)
        return timeFromOffset
        
    }
    
    /**
     视频播放过程中，传入当前播放的时间，导航条进行相应的展示
     
     @param time 当前播放时间
     */
    
    func seekToTime(_ time: CGFloat)
    {
        if isDragging || isDecelerate || self.videoDuration <= 0
        {
            return
        }
        
        if self.actualDuration == 0
        {
            self.actualDuration = self.videoDuration
        }
        
        let mappedTime = (self.videoDuration / self.actualDuration) * time
        let offset = self.offsetWithTime(mappedTime)
        DispatchQueue.main.async {
            self.collectionView.contentOffset = CGPoint(x: offset - self.indicator.center.x, y: self.collectionView.contentOffset.y)
        }
    }
    
    /**
     取消当前控件行为 例如：在滑动时，调用此方法则不再滑动
     */
    func cancel()
    {
        self.collectionView.setContentOffset(self.collectionView.contentOffset, animated: false)
        isDragging = false
        isDecelerate = false
    }
    
    /**
     添加显示元素 （例如加动图后，需要构建timelineItem对象，并且传入用来显示）
     
     @param timelineItem 显示元素
     */
    func addTimelineItem(_ timelineItem: TimelineItem)
    {
        self.timelineItems.append(timelineItem)
        self.setNeedsUpdateGreyViews()
    }
    
    func setNeedsUpdateGreyViews()
    {
        self.generateTimelinePercentItems()
    }
    
    /**
     删除显示元素
     
     @param timelineItem 显示元素
     */
    func removeTimelineItem(_ timelineItem: TimelineItem)
    {
        if let index = self.timelineItems.firstIndex(of: timelineItem)
        {
            self.timelineItems.remove(at: index)
            self.allPasterviewsEndEited()
        }
    }
    
    func allPasterviewsEndEited()
    {
        currentItem = nil
        self.setNeedsUpdateGreyViews()

    }
    
    
    /**
     从vid获取AliyunTimelineItem对象
     
     @param obj obj
     @return AliyunTimelineItem
     */
    func getTimelineItemWithOjb(_ obj:AnyObject)->TimelineItem?
    {
        var targetItem: TimelineItem?
        for item in self.timelineItems {
            if item.obj! === obj
            {
                targetItem = item
                break
            }
        }
        return targetItem
    }
    
    
    /**
     动效滤镜的显示元素
     添加元素
     
     @param filterItem 动效滤镜元素
     */
    func addTimelineFilterItem(_ filterItem:TimelineFilterItem)
    {
        self.timelineFilterItems.append(filterItem)
        self.setNeedsUpdateGreyViews()
    }
    
    /**
     更新进度
     
     @param filterItem 动效滤镜
     */
    func updateTimelineFilterItems(_ filterItem:TimelineFilterItem)
    {
        if !self.timelineFilterItems.contains(filterItem)
        {
            self.timelineFilterItems.append(filterItem)
        }
        self.setNeedsUpdateGreyViews()
    }
    
    /**
     删除动效滤镜显示元素
     
     @param filterItem 动效滤镜元素
     */
    func removeTimelineFilterItem(_ filterItem:TimelineFilterItem)
    {
        if let index = self.timelineFilterItems.firstIndex(of: filterItem)
        {
            self.timelineFilterItems.remove(at: index)
            self.setNeedsUpdateGreyViews()
        }
    }
    
    /**
     删除最后一个滤镜显示元素
     */
    func removeLastFilterItemFromTimeline()
    {
        self.timelineFilterItems.removeAll()
        self.setNeedsUpdateGreyViews()
    }
    
    /**
     更新透明度
     
     @param alpha 透明度
     */
    func updateTimelineViewAlpha(_ alpha:CGFloat)
    {
        self.backgroundColor = UIColor.clear
        self.collectionView.backgroundColor = BackgroundColor
    }

    
    func timeWithOffset(_ offset: CGFloat)->CGFloat
    {
        let time = (offset / (CGFloat(self.photoCounts.count) * self.itemWidth)) * self.videoDuration
        return time
    }
    
    func offsetWithTime(_ time: CGFloat)->CGFloat
    {
        let offset = (time/self.videoDuration) * self.itemWidth * CGFloat(self.photoCounts.count)
        return offset
    }
    
    /**
     装载数据，用来显示
     
     @param clips 媒体片段
     @param segment 段长（指的是一个屏幕宽度的视频时长  单位：s）
     @param photos 一个段长上需要显示的图片个数 默认为8
     */
    
    func setMediaClips(_ clips:[TimelineMediaInfo], segment: CGFloat, photos: Int)
    {
        self.segment = segment
        self.photosPersegment = photos
        
        if photos <= 0
        {
            self.photosPersegment = 8
        }
        
        self.setupSubviews()
        self.generateImagesWithMediaInfoClips(clips, rotate: 0)
        self.generateTimelinePercentItems()
        
    }
    
    func setupSubviews()
    {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: self.itemWidth, height: self.itemHeight)
        
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.addSubview(self.collectionView)
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: self.na_centerX, bottom: 0, right: self.na_centerX)
        self.collectionView.register(TimelineItemCell.self, forCellWithReuseIdentifier: "TimelineItemCell")
        
        self.indicator = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: self.na_height))
        let indicatorCenterView = UIView(frame: CGRect(x: 6, y: 0, width: 2, height: self.indicator.na_height))
        indicatorCenterView.backgroundColor = self.indicatorColor == nil ? YellowMainColor : self.indicatorColor
        self.indicator.addSubview(indicatorCenterView)
        
        self.addSubview(self.indicator)
        
        var indicatorCenter = self.indicator.center
        self.indicator.backgroundColor  = UIColor.ColorHexWithAlpha("#FFFFFF", 0.4)
        indicatorCenter.x = self.na_centerX
        self.indicator.center = indicatorCenter
        
    }
    
    func generateImagesWithMediaInfoClips(_ clips:[TimelineMediaInfo], rotate:Int)
    {
        generator = AssetImageGenerator()
        
        for info in clips
        {
            if info.mediaType == .photo
            {
                generator?.addImageWithPath(info.path!, duration: info.duration!, animDuration: 0)
            }else{
                generator?.addVideoWithPath(info.path!, startTime: info.startTime!, duration: info.duration!, animDuration: 0)
            }
        }
        
        self.videoDuration = (generator?.duration)!
        let singleTime = self.segment! / CGFloat(self.photosPersegment) // 一个图片的时间
        self.singleItemDuration = singleTime
        
        var timeValues = [NSValue]()
        var idx = 0
        while CGFloat(idx)*singleTime < self.videoDuration {
            let time = CGFloat(idx) * singleTime
            timeValues.append(NSNumber(value: Float(time)))
            idx += 1
        }
        
        self.photoCounts = timeValues
        self.totalItemsWidth = self.itemWidth * CGFloat(self.photoCounts.count)
        generator?.imageCount = self.photoCounts.count
        generator?.outputSize = CGSize(width: 100, height: 100)
        generator?.generateWithCompleteHandler({ (image) in
            self.addGenateImage(image)
            if self.coverImage == nil
            {
                self.coverImage = image
            }
        })
    }
    
    func generateTimelinePercentItems()
    {
        self.timelinePercentItems.removeAll()
        self.timelinePercentFilterItems.removeAll()
        
        let itemDuration = self.videoDuration / CGFloat(self.photoCounts.count)
        
        for i in 1...self.photoCounts.count
        {
            var mappedBeginTime = itemDuration * CGFloat(i-1)
            var mappedEndTime = itemDuration * CGFloat(i)
            
            if i == self.photoCounts.count
            {
                if mappedEndTime > self.videoDuration
                {
                    mappedEndTime = self.videoDuration
                }
            }
            
            if self.actualDuration == 0
            {
                self.actualDuration = self.videoDuration
            }
            
            mappedBeginTime *= (self.actualDuration/self.videoDuration)
            mappedEndTime *= (self.actualDuration/self.videoDuration)
            
            let timelinePercents = self.checkPasterExistBetween(mappedBeginTime, endTime: mappedEndTime)
            self.timelinePercentItems.append(timelinePercents)
            
            let timelineFilterPercents = self.checkFilterExistBetween(mappedBeginTime, endTime: mappedEndTime)
            self.timelinePercentFilterItems.append(timelineFilterPercents)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func checkPasterExistBetween(_ beginTime: CGFloat, endTime: CGFloat) ->[TimelinePercent]
    {
        var timelinePercents = [TimelinePercent]()
        
        for item in self.timelineItems
        {
            if beginTime > item.startTime && item.endTime >= beginTime && item.endTime <= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = 0.0
                timelinePercent.rightPercent = (item.endTime - beginTime) / (endTime - beginTime)
                timelinePercents.append(timelinePercent)
            }
            
            if beginTime >= item.startTime && item.endTime >= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = 0.0
                timelinePercent.rightPercent = 1.0
                timelinePercents.append(timelinePercent)
            }
            
            if item.startTime >= beginTime && item.endTime <= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = (item.startTime - beginTime) / (endTime - beginTime)
                timelinePercent.rightPercent = (item.endTime - beginTime) / (endTime - beginTime)
                timelinePercents.append(timelinePercent)
            }
            
            if item.startTime >= beginTime && item.startTime <= endTime && item.endTime >= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = (item.startTime - beginTime) / (endTime - beginTime)
                timelinePercent.rightPercent = 1.0
                timelinePercents.append(timelinePercent)
            }
        }
        return timelinePercents
    }
    
    func checkFilterExistBetween(_ beginTime: CGFloat, endTime: CGFloat)->[TimelinePercent]
    {
        var timelineFilterPercents = [TimelinePercent]()
        for item in self.timelineFilterItems
        {
            if beginTime > item.startTime && item.endTime >= beginTime && item.endTime <= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = 0.0
                timelinePercent.rightPercent = (item.endTime - beginTime) / (endTime - beginTime)
                timelinePercent.color = item.displayColor
                timelineFilterPercents.append(timelinePercent)
            }
            
            if beginTime >= item.startTime && item.endTime >= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = 0.0
                timelinePercent.rightPercent = 1.0
                timelinePercent.color = item.displayColor
                timelineFilterPercents.append(timelinePercent)
            }
            
            if item.startTime >= beginTime && item.endTime <= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = (item.startTime - beginTime) / (endTime - beginTime)
                timelinePercent.rightPercent = (item.endTime - beginTime) / (endTime - beginTime)
                timelinePercent.color = item.displayColor
                timelineFilterPercents.append(timelinePercent)
            }
            
            if item.startTime >= beginTime && item.startTime <= endTime && item.endTime >= endTime
            {
                let timelinePercent = TimelinePercent()
                timelinePercent.leftPercent = (item.startTime - beginTime) / (endTime - beginTime)
                timelinePercent.rightPercent = 1.0
                timelinePercent.color = item.displayColor
                timelineFilterPercents.append(timelinePercent)
            }
        }
        return timelineFilterPercents
    }
    
    func addGenateImage(_ image: UIImage)
    {
        self.photoItems.append(image)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK: Touches=========
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        DispatchQueue.main.async {
            self.setNeedsUpdateGreyViews()
        }
        
  
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    
}

extension TimelineView: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoCounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineItemCell", for: indexPath) as! TimelineItemCell
        
        var image:UIImage? = nil
        if indexPath.row < self.photoItems.count
        {
            image = self.photoItems[indexPath.row]
        }
        
        let idx = indexPath.row + 1
        
        let itemDuration = self.videoDuration / CGFloat(self.photoCounts.count)
        
        let mappedBeginTime = itemDuration * CGFloat(idx - 1)
        var mappedEndTime = itemDuration * CGFloat(idx)
        
        if idx == self.photoCounts.count
        {
            if mappedEndTime > self.videoDuration {
                mappedEndTime = self.videoDuration
            }
        }
        
        let timelinePercent = self.timelinePercentItems[indexPath.row]
        let timelineFilterPercent = self.timelinePercentFilterItems[indexPath.row]
        
        cell.setMappedBeginTime(mappedBeginTime, endTime: mappedEndTime, image: image, percents: timelinePercent, filterPercents: timelineFilterPercent)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isDragging || isDecelerate
        {
            var offsetPoint = self.indicator.center.x + self.collectionView.contentOffset.x
            if offsetPoint < 0
            {
                offsetPoint = 0
            }else if offsetPoint > self.totalItemsWidth
            {
                offsetPoint = self.totalItemsWidth
            }
            
            var timeFromOffset = self.timeWithOffset(offsetPoint)
            
            if self.actualDuration == 0
            {
                self.actualDuration = self.videoDuration
            }
            
            timeFromOffset *= (self.actualDuration/self.videoDuration)
            self.delegate?.timelineDraggingAtTime(timeFromOffset)
        }
        
        DispatchQueue.main.async {
            var currentTime = self.getCurrentTime()
            if self.actualDuration == 0
            {
                self.actualDuration = self.videoDuration
            }
            
            currentTime *= (self.actualDuration/self.videoDuration)
            self.delegate?.timelineCurrentTime(currentTime, duration: self.actualDuration)
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
        self.delegate?.timelineBeginDragging()
        
        currentItem = nil
        self.setNeedsUpdateGreyViews()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
        
        if !isDragging && !isDecelerate
        {
            var offsetPoint = self.indicator.center.x + self.collectionView.contentOffset.x
            if offsetPoint < 0
            {
                offsetPoint = 0
            }else if offsetPoint > self.totalItemsWidth
            {
                offsetPoint = self.totalItemsWidth
            }
            
            var timeFromOffset = self.timeWithOffset(offsetPoint)
            
            if self.actualDuration == 0
            {
                self.actualDuration = self.videoDuration
            }
            
            timeFromOffset *= (self.actualDuration/self.videoDuration)
            
            if decelerate
            {
                self.delegate?.timelineDraggingAtTime(timeFromOffset)
            }else{
                self.delegate?.timelineEndDraggingAndDecelerate(timeFromOffset)
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isDecelerate = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDecelerate = false
        if !isDragging && !isDecelerate
        {
            var offsetPoint = self.indicator.center.x + self.collectionView.contentOffset.x
            if offsetPoint < 0
            {
                offsetPoint = 0
            }else if offsetPoint > self.totalItemsWidth
            {
                offsetPoint = self.totalItemsWidth
            }
            
            var timeFromOffset = self.timeWithOffset(offsetPoint)
            
            if self.actualDuration == 0
            {
                self.actualDuration = self.videoDuration
            }
            
            timeFromOffset *= (self.actualDuration/self.videoDuration)
            
            self.delegate?.timelineEndDraggingAndDecelerate(timeFromOffset)
        }
    }
}
