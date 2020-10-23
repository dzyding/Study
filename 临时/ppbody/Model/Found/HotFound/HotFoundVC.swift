//
//  HotFoundVC.swift
//  PPBody
//
//  Created by edz on 2020/7/9.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class HotFoundVC: BaseVC, BaseRequestProtocol {
    
    var re_listView: UIScrollView {
        return tableView
    }
    
    @IBOutlet weak var tableView: UITableView!
    // 
    private var isCurPlayerPause: Bool = false
    
    private var currentIndex: Int = 0
    
    let itemInfo: IndicatorInfo
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listAddHeader()
        listApi(1)
        tableView.dzy_registerCellNib(HotFoundVideoCell.self)
        tableView.dzy_registerCellNib(HotFoundImageCell.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func applicationBecomeActive() {
//        let cell = collectionview.cellForItem(at: IndexPath.init(row: currentIndex, section: 0))  as? VideoTopicDetailCell
//        if cell != nil && !isCurPlayerPause {
//            cell!.play()
//        }
    }
    
    @objc func applicationEnterBackground() {
//        let cell = collectionview.cellForItem(at: IndexPath.init(row: currentIndex, section: 0)) as? VideoTopicDetailCell
//        if cell != nil {
//            isCurPlayerPause = cell!.playerView.rate() == 0 ? true :false
//            cell!.pause()
//        }
    }
    
    func listApi(_ page: Int) {
        let request = BaseRequest()
        request.url = BaseURL.TopicList
        request.dic = ["type" : "10"]
        request.page = [page, 10]
        request.start { (data, error) in
            self.pageOperation(data: data, error: error)
        }
    }
}

extension HotFoundVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic = dataArr[indexPath.row]
        let video = dic.stringValue("video") ?? ""
        if video.count > 1 {
            let cell = tableView.dzy_dequeueReusableCell(HotFoundVideoCell.self)
            cell?.updateUI(dic, indexPath: indexPath)
            return cell!
        }else {
            let cell = tableView.dzy_dequeueReusableCell(HotFoundImageCell.self)
            cell?.updateUI(dic)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 722
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = tableView.indexPathsForVisibleRows
        print(cells)
    }
}

extension HotFoundVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
