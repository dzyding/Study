//
//  MusicTableView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import MediaPlayer

class MusicTableViewVC: BaseVC {
    
    var itemInfo = IndicatorInfo(title: "View")

    var selectSection = -1

    @IBOutlet weak var tableview: UITableView!
    
    var lastSection: MusicPickHeaderView?
    
    convenience init(itemInfo: IndicatorInfo) {
        self.init()
        self.itemInfo = itemInfo
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "选择歌曲"
        
        tableview.register(UINib(nibName: "MusicPickHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MusicPickHeaderView")
        tableview.register(UINib(nibName: "MusicPickCell", bundle: nil), forCellReuseIdentifier: "MusicPickCell")
        let refresh = Refresher{ [weak self] (loadmore) -> Void in
            self?.getData(loadmore ? (self!.currentPage)!+1 : 1)
        }
        
        tableview.srf_addRefresher(refresh)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData(1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if  lastSection != nil {
            lastSection?.reset()
        }
        selectSection = -1
        self.tableview.reloadData()
        MusicPickPlayer.player.destroy()
    }
    
    
    func getData(_ page: Int)
    {
        let request = BaseRequest()
        
        if self.itemInfo.title == "热门音乐"
        {
            request.url = BaseURL.HotMusic
        }else{
            request.url = BaseURL.CollectionMusic
        }
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

extension MusicTableViewVC: IndicatorInfoProvider,UITableViewDelegate,UITableViewDataSource,MusicPickHeaderViewDelegate
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

    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
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
        header.setData(dataArr[section], section: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicPickCell", for: indexPath) as! MusicPickCell
        cell.sureBtn.tag = indexPath.section
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parent = self.parent as! MusicPickVC
        parent.deleagte?.selectMusic(dataArr[indexPath.section])
        parent.navigationController?.popViewController(animated: true)
    }
    
}
