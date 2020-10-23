//
//  MusicPickVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol MusicPickSelectDelegate: NSObjectProtocol{
    func selectMusic(_ dic: [String:Any])
}

class MusicPickVC: ButtonBarPagerTabStripViewController
{
    var isReload = false
    
    weak var deleagte:MusicPickSelectDelegate?
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    var lastSection: MusicPickHeaderView?
    var selectSection = -1
    
    deinit {
        MusicPickPlayer.player.destroy()
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 10
        
        settings.style.selectedBarBackgroundColor = YellowMainColor
        
        super.viewDidLoad()
        
        self.title = "选择音乐"
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        self.searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = Text1Color
            newCell?.label.textColor = YellowMainColor
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            } else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        
        tableview.register(UINib(nibName: "MusicPickHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MusicPickHeaderView")
        tableview.register(UINib(nibName: "MusicPickCell", bundle: nil), forCellReuseIdentifier: "MusicPickCell")
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        
        tableview.srf_addRefresher(refresh)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = MusicTableViewVC(itemInfo: "热门音乐")
        let child_2 = MusicTableViewVC(itemInfo: "我的收藏")
        
        guard isReload else {
            return [child_1, child_2]
        }
        
        var childViewControllers = [child_1, child_2]
        
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
    
    
    func generateMusicWithPath(path: String, start: Float, duration: Float) -> AVMutableComposition
    {
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        let mutableComposition = AVMutableComposition()
        let mutableCompositionAudioTrack = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = asset.tracks(withMediaType: .audio)[0]
        let startTime = CMTime(value: CMTimeValue(1000*start), timescale: 1000)
        let stopTime = CMTime(value: CMTimeValue(1000*(start + duration)), timescale: 1000)
        let exportTimeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
        try! mutableCompositionAudioTrack?.insertTimeRange(exportTimeRange, of: audioTrack, at: CMTime.zero)
        return mutableComposition
    }
    
    @objc func textFieldDidChange(_ textfield : UITextField)
    {
        search(by: textfield.text!)
    }
    
    //搜索数据
    func search(by key: String)
    {
        if key.count != 0
        {
            self.tableview.isHidden = false
            getData(1)
            
        }else{
            self.tableview.isHidden = true
            if  lastSection != nil {
                lastSection?.reset()
            }
            selectSection = -1
            
            self.dataArr.removeAll()
            self.tableview.reloadData()
        }
        
    }
    
    func getData(_ page: Int)
    {
        let request = BaseRequest()
        request.dic = ["key": self.searchTF.text!]
        request.url = BaseURL.HotMusic
        request.isUser = true
        request.page = [page,20]
        request.start { (data, error) in
            
            self.tableview.srf_endRefreshing()
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.page = data?["page"] as! Dictionary<String, Any>?
            
            let listData = data?["list"] as! Array<Dictionary<String,Any>>
            
            if self.currentPage == 1
            {
                
                self.dataArr.removeAll()
                
                if listData.isEmpty
                {
                }else{
                    self.tableview.reloadData()
                }
                if self.currentPage! < self.totalPage!
                {
                    self.tableview.srf_canLoadMore(true)
                }else{
                    self.tableview.srf_canLoadMore(false)
                }
            }else if self.currentPage == self.totalPage
            {
                self.tableview.srf_canLoadMore(false)
            }
            
            self.dataArr.append(contentsOf: listData)
            self.tableview.reloadData()
        }
    }
    
    //收藏音乐
    func collectMusic(_ musicId: Int, collect:Bool)
    {
        let request = BaseRequest()
        request.dic = ["musicId":"\(musicId)","type": collect ? "10" : "20"]
        request.url = BaseURL.CollectMusic
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                return
            }
        }
    }
}

extension MusicPickVC:UITableViewDelegate,UITableViewDataSource,MusicPickHeaderViewDelegate
{
    func collectMusicId(_ musicId: Int, isCollect: Bool, index: Int) {
        self.collectMusic(musicId, collect: isCollect)
        
        var dic = self.dataArr[index]
        dic["isCollect"] = isCollect ? 1 : 0
        self.dataArr[index] = dic
    }
    
    
    func playPath(_ path: String, start: Float, duration: Float) {
        MusicPickPlayer.player.playCurrentItem(path: path, start: start, duration: duration)
    }
    
    // MARK: - MusicPickHeaderViewDelegate
    func tapHeaderView(_ head: MusicPickHeaderView) {
        let tapSection = head.tag
        if tapSection != selectSection
        {
            if lastSection != nil && lastSection != head{
                lastSection?.reset()
            }
            lastSection = head
            // bug 点 By Nathan 待修复
            //            self.tableview.beginUpdates()
            //
            //            if selectSection >= 0
            //            {
            //                self.tableview.deleteRows(at: [IndexPath(row: 0, section: selectSection)], with: .fade)
            //            }
            //
            //            selectSection = tapSection
            //            self.tableview.reloadSections(IndexSet(integer: tapSection), with: .none)
            //            self.tableview.endUpdates()
            selectSection = tapSection
            self.tableview.reloadData()
        }
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == selectSection
        {
            return 1
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableview.dequeueReusableHeaderFooterView(withIdentifier: "MusicPickHeaderView") as! MusicPickHeaderView
        header.tag = section
        header.delegate = self
        header.setData(self.dataArr[section],section: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPickCell", for: indexPath) as! MusicPickCell
        cell.sureBtn.tag = indexPath.section
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.deleagte?.selectMusic(self.dataArr[indexPath.section])
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
