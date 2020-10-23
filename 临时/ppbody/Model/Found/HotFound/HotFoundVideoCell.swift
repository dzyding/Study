//
//  HotFoundVideoCell.swift
//  PPBody
//
//  Created by dingzhiyuan on 2020/7/22.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit
import DynamicButton
import Alamofire

class HotFoundVideoCell: UITableViewCell {
// ---- 数据相关
    private var indexPath: IndexPath?
    
    private var dic: [String : Any]?
    
    private var tid: String?
    
    private var vid: String?
    
    private var dataRequest: DataRequest?
    /// 是否准备好开始
    private var isPlayerReady = false
    /// 上一次点击时间 用来判断是双击还是单击
    private var lastTapTime:TimeInterval = 0
// ---- 数据相关
    
// ---- 通用 UI
    /// 姓名
    @IBOutlet weak var nameLB: UILabel!
    /// 标签
    @IBOutlet weak var briefLB: UILabel!
    /// 头像
    @IBOutlet weak var logoIV: UIImageView!
    /// 内容
    @IBOutlet weak var contentLB: UILabel!
    /// 0人浏览
    @IBOutlet weak var lookNumLB: UILabel!
    /// 共0条评论
    @IBOutlet weak var commentLB: UILabel!
    /// 上面的评论
    @IBOutlet weak var topCommentLB: UILabel!
    /// 下面的评论
    @IBOutlet weak var bottomCommentLB: UILabel!
    /// 80 50 0
    @IBOutlet weak var commentHLC: NSLayoutConstraint!
// ---- 通用 UI
    
    /// 暂停的占位图
    @IBOutlet weak var coverIV: UIImageView!
    /// 开始按钮
    @IBOutlet weak var playBtn: UIButton!
    /// 背景视图
    @IBOutlet weak var bgView: UIView!
    
    private lazy var playerView: AVPlayerView = {[weak self] in
        let pv = AVPlayerView()
        pv.delegate = self
        return pv
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playerView.cancelLoading()
        self.dataRequest?.cancel()
        isPlayerReady = false
    }
    
    private func initUI() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleGesture(sender:))
        )
        bgView.addGestureRecognizer(tap)
        bgView.insertSubview(playerView, belowSubview: playBtn)
        
        playerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    func updateUI(_ dic: [String : Any], indexPath:IndexPath) {
        self.indexPath = indexPath
        self.dic = dic
        tid = dic.stringValue("tid")
        vid = dic.stringValue("video")
        coverIV.setCoverImageUrl(dic.stringValue("cover"))
        playBtn.isHidden = false
        coverIV.isHidden = false
        baseUpdateUI(dic)
        getUrlFromVid(vid)
    }
    
//    MARK: - 获取链接
    private func getUrlFromVid(_ vid: String?) {
        guard let vid = vid else {return}
        if AlivideoPlayCache.cache.videoCache.keys.contains(where: {$0 == vid}) {
            if let dic = AlivideoPlayCache.cache.videoCache[vid] as? [String:Any],
                let requestTime = dic["time"] as? Date
            {
                let second = Date().timeIntervalSince(requestTime)
                if second/60 > 4 { //大于4分钟需要重新获取client
                    getVideoODUrlApi(vid)
                }else{
                    dic.stringValue("url").flatMap({
                        playerView.setPlayerSourceUrl(url: $0)
                    })
                }
            }
        }else{
            getVideoODUrlApi(vid)
        }
    }
    
//    MARK: - Api
    private func getVideoODUrlApi(_ vid: String) {
        let request = BaseRequest()
        request.dic = ["vid":vid]
        request.url = BaseURL.GetVideoURL
        request.start { (data, error) in
            guard error == nil else {
                //执行错误信息
                return
            }
            let videoInfo = data!["videoInfo"] as! [String:Any]
            let playURL = videoInfo["playURL"] as! String
            let requestTime = Date()
            let dic:[String : Any] = ["url":playURL,"time":requestTime]
            AlivideoPlayCache.cache.videoCache[vid] = dic
            self.playerView.setPlayerSourceUrl(url: playURL)
        }
        dataRequest = request.currentRequest
    }
    
    func play() {
        if playBtn.isHidden && isPlayerReady {
            playerView.play()
            playBtn.isHidden = true
        }
    }
    
    func pause() {
        playerView.pause()
    }
    
    func replay() {
        playBtn.isHidden = true
        playerView.replay()
    }
    
    func cancelLoading() {
        self.playerView.cancelLoading()
    }
    
    @objc func handleGesture(sender: UITapGestureRecognizer) {
        let time = CACurrentMediaTime()
        //判断当前点击时间与上次点击时间的时间间隔
        if (time - lastTapTime) > 0.25 {
            //推迟0.25秒执行单击方法
            perform(#selector(tapSingleDid), with: nil, afterDelay: 0.25)
        } else {
            //取消执行单击方法
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(tapSingleDid), object: nil)
            //执行连击显示爱心的方法
            tapDoubleDid(sender)
        }
        //更新上一次点击时间
        lastTapTime = time
    }
    
     @objc private func tapSingleDid(){
        showPauseViewAnim(rate: playerView.rate())
        playerView.updatePlayerState()
    }

    @objc private func tapDoubleDid(_ tap: UITapGestureRecognizer){
        ControllerLikeAnimation.likeAnimation.createAnimationWithTouch(tap)
    }
    
    //点击效果
    private func showPauseViewAnim(rate:CGFloat) {
        if rate == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.playBtn.alpha = 0.0
            }) { finished in
                self.playBtn.isHidden = true
            }
        } else {
            playBtn.isHidden = false
            playBtn.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
            playBtn.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.playBtn.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }) { finished in
            }
        }
    }
    
    deinit {
        print("VideoTopicDetailCell deinit=====")
        //        self.playerView.cancelLoading()
    }
}

extension HotFoundVideoCell: AVPlayerUpdateDelegate {
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            break
        case .readyToPlay:
//            self.controllerview.startLoadingPlayItemAnim(false)
            self.isPlayerReady = true
        case .failed:
            break
        @unknown default:
            break
        }
    }
}

extension HotFoundVideoCell: HotFoundCellUIProtocol {
    var p_nameLB: UILabel? {
        return nameLB
    }
    
    var p_briefLB: UILabel? {
        return briefLB
    }
    
    var p_logoIV: UIImageView? {
        return logoIV
    }
    
    var p_contentLB: UILabel? {
        return contentLB
    }
    
    var p_lookNumLB: UILabel? {
        return lookNumLB
    }
    
    var p_commentLB: UILabel? {
        return commentLB
    }
    
    var p_topCommentLB: UILabel? {
        return topCommentLB
    }
    
    var p_bottomCommentLB: UILabel? {
        return bottomCommentLB
    }
    
    var p_commentHLC: NSLayoutConstraint? {
        return commentHLC
    }
}
