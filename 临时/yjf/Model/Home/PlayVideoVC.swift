//
//  PlayVideoVC.swift
//  YJF
//
//  Created by edz on 2019/8/19.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import AVFoundation

class PlayVideoVC: BaseVC {
    
    private let url: String
    
    private var isPlayerReady = false

    @IBOutlet weak var playBtn: UIButton!
    
    init(_ url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target:self, action: #selector(tapSingleDid))
        view.addGestureRecognizer(tap)
        
        playerView.setPlayerSourceUrl(url: url)
        view.insertSubview(playerView, at: 0)
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func tapSingleDid(){
        showPauseViewAnim(playerView.rate())
        playerView.updatePlayerState()
    }

    @IBAction func playAction(_ sender: UIButton) {
        if !playBtn.isHidden && isPlayerReady {
            playerView.play()
            playBtn.isHidden = true
            playBtn.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    //点击效果
    private func showPauseViewAnim(_ rate:CGFloat) {
        if rate == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.playBtn.alpha = 0.0
            }) { _ in
                self.playBtn.isHidden = true
            }
        } else {
            playBtn.isHidden = false
            playBtn.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
            playBtn.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.playBtn.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }) { _ in
            }
        }
    }
    
    //    MARK: - 懒加载
    lazy var playerView:AVPlayerView = {[weak self] in
        let pv = AVPlayerView()
        pv.delegate = self
        return pv
    }()
}

extension PlayVideoVC: AVPlayerUpdateDelegate {
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isPlayerReady = true
        default:
            break
        }
    }
}
