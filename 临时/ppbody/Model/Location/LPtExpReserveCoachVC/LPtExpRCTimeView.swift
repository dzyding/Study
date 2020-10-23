//
//  LocationRCTimeView.swift
//  PPBody
//
//  Created by edz on 2019/10/25.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LPtExpRCTimeView: UIView, InitFromNibEnable {

    @IBOutlet weak var collectionView: UICollectionView!
    /// 日期的主滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    /// 日期的
    @IBOutlet weak var dateStackView: UIStackView!
    /// 日期的线
    @IBOutlet weak var dateLine: UIView!
    
    @IBOutlet weak var dateLineLeftLC: NSLayoutConstraint!
    /// 白天
    @IBOutlet weak var lightTimeBtn: UIButton!
    /// 夜晚
    @IBOutlet weak var nightTimeBtn: UIButton!
    /// 白天、夜晚 的主界面
    @IBOutlet weak var timeView: UIView!
    /// 白天、夜晚 的线
    @IBOutlet weak var timeLine: UIView!
    
    @IBOutlet weak var timeLineLeftLC: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewHeightLC: NSLayoutConstraint!
    /// 预约时间：今天(10月16日) 10:00
    @IBOutlet weak var reserveTimeLB: UILabel!
    /// 预约时间 (接口用的)
    var reserveTime: String?
    /// 分割线 18:30
    private let lineTime = 18 * 60 + 30
    /// 判断白天还是黑夜
    private var isLight = true
    
    private var isOpen = false
    /// 可用时间
    private var lightTimes: [(Int, Bool)] = []
    private var nightTimes: [(Int, Bool)] = []
    /// 可用星期几
    private var days: [Int] = []
    /// 可用日期
    private var dates: [(String, String, Bool)] = []
    
    private var count: Int {
        return isLight ? lightTimes.count : nightTimes.count
    }
    
    private var row: Int {
        return count % 4 == 0 ? (count / 4) : (count / 4 + 1)
    }
    
//    MARK: - 展开、收起
    private func openAction() {
        isOpen = !isOpen
        updateHeight()
        collectionView.reloadData()
    }
    
//    MARK: 更新高度
    func updateHeight() {
        var height: CGFloat = 0
        if row <= 2 {
            height = 30.0 * CGFloat(row) + CGFloat(row) * 15.0
        }else {
            if isOpen {
                height = 30.0 * CGFloat(row) + 15.0 * CGFloat(row - 1) + 45.0
            }else {
                height = 30.0 * 2.0 + 15.0 + 45.0
            }
        }
        collectionViewHeightLC.constant = height
    }
    
//    MARK: - 白天、晚上
    @IBAction func timeAction(_ sender: UIButton) {
        guard !sender.isSelected else {return}
        sender.isSelected = true
        isLight = sender == lightTimeBtn
        let btn = sender == lightTimeBtn ? nightTimeBtn : lightTimeBtn
        btn?.isSelected = false
        timeLineLeftLC.constant = 16.0 + sender.frame.minX
        
        UIView.animate(withDuration: 0.25) {
            self.timeView.setNeedsLayout()
            self.timeView.layoutIfNeeded()
        }
        updateHeight()
        collectionView.reloadData()
    }
    
//    MARK: - 选择日期
    private func dateAction(_ tag: Int) {
        guard let cell = dateStackView.arrangedSubviews[tag] as? LGymGCDateCell else {return}
        dateLineLeftLC.constant = cell.frame.minX
        UIView.animate(withDuration: 0.25) {
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
        }
        
        (0..<dates.count).forEach { (index) in
            dates[index].2 = false
        }
        dates[tag].2 = true
        (0..<dates.count).forEach { (index) in
            let cell = (dateStackView.arrangedSubviews[index] as? LGymGCDateCell)
            cell?.updateUI(dates[index])
        }
        updateSelectedDate()
    }
//    MARK: - 选择时间
    private func timeAction(_ index: Int) {
        nightTimes = nightTimes.map({($0.0, false)})
        lightTimes = lightTimes.map({($0.0, false)})
        if isLight {
            lightTimes[index].1 = true
        }else {
            nightTimes[index].1 = true
        }
        updateSelectedDate()
        collectionView.reloadData()
    }
    
//    MARK: - 更新选中日期
    private func updateSelectedDate() {
        guard let date = dates.filter({$0.2}).first,
            let time = (lightTimes + nightTimes).filter({$0.1}).first
        else {return}
        let temp = date.1
            .replacingOccurrences(of: "-", with: "月") + "日"
        reserveTimeLB.text = "预约时间：\(date.0)(\(temp)) \(ToolClass.getTimeStr(time.0))"
        dzy_date8().description
            .components(separatedBy: "-")
            .first
            .flatMap({
                reserveTime = $0 + "-" + date.1 + " " +  ToolClass.getTimeStr(time.0) + ":00"
        })
    }
    
//    MARK: - 初始化界面
    func initUI(_ info: String, duration: Int) {
        dealTheTimeAndDateStr(info, duration: duration)
        var tempDates = LocationVCHelper
            .getNextNumDates(6, range: days)
        tempDates[0].2 = true
        dates = tempDates
        self.isOpen = false
        updateHeight()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView
            .dzy_registerCellFromNib(LPtExpRCTimeCell.self)
        let footerClass = LPtExpRCTimeMoreFooterView.self
        collectionView
            .dzy_registerFooterFromNib(footerClass)
        
        dates.enumerated().forEach({ (index, value) in
            let cell = LGymGCDateCell.initFromNib()
            cell.tag = index
            cell.updateUI(value)
            cell.handler = { [weak self] tag in
                self?.dateAction(tag)
            }
            dateStackView.addArrangedSubview(cell)
        })
    }
    
//    MARK: - 处理日期和时间
    private func dealTheTimeAndDateStr(_ str: String, duration: Int) {
        let strArr = str.components(separatedBy: " ")
        guard strArr.count == 2 else {
            ToolClass.showToast("无效的时间格式", .Failure)
            return
        }
        getCanUseDays(strArr[0])
        getCanUseTimes(strArr[1], duration: duration)
    }
    
    //MARK: - 计算可用时间
    private func getCanUseTimes(_ str: String, duration: Int) {
        // 10:00~22:00
        let tempArr = str.components(separatedBy: ["~", "-"])
        guard tempArr.count == 2 else {
            ToolClass.showToast("无效的时间格式", .Failure)
            return
        }
        var startTime = dealTheTimeStr(tempArr[0])
        let endTime = dealTheTimeStr(tempArr[1]) - duration
        // 更新时间按钮的 title
        updateTimeRangeTitle(startTime, endTime: endTime)
        while startTime < endTime {
            let svalue = (startTime, false)
            if startTime < lineTime {
                lightTimes.append(svalue)
            }else if startTime > lineTime {
                nightTimes.append(svalue)
            }else {
                lightTimes.append(svalue)
                nightTimes.append(svalue)
            }
            startTime += 30
        }
        let evalue = (endTime, false)
        if endTime >= lineTime {
            nightTimes.append(evalue)
        }else {
            lightTimes.append(evalue)
        }
    }
    
    private func dealTheTimeStr(_ str: String) -> Int {
        // 10:00
        let arr = str.components(separatedBy: ":")
        guard arr.count == 2 else {
            ToolClass.showToast("无效的时间格式", .Failure)
            return 0
        }
        let hour = (Int(arr[0]) ?? 0) * 60
        let min = Int(arr[1]) ?? 0
        return hour + min
    }
    
    private func updateTimeRangeTitle(_ startTime: Int, endTime: Int) {
        let sStr = ToolClass.getTimeStr(startTime)
        let eStr = ToolClass.getTimeStr(endTime)
        if startTime < lineTime {
            let lightRangeStr = "白天(\(sStr)-18:30)"
            lightTimeBtn.setTitle(lightRangeStr, for: .normal)
        }else {
            lightTimeBtn.setTitle("白天(暂无)", for: .normal)
        }
        if endTime > lineTime {
            let nightRangeStr = "晚上(18:30-\(eStr))"
            nightTimeBtn.setTitle(nightRangeStr, for: .normal)
        }else {
            nightTimeBtn.setTitle("晚上(暂无)", for: .normal)
        }
    }
    
    //MARK: -  计算可用星期
    private func getCanUseDays(_ str: String) {
        let tempArr = str.components(separatedBy: [",", "，"])
        days = tempArr.compactMap({Int($0)})
    }
}

extension LPtExpRCTimeView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isOpen ? count : min(8, count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(LPtExpRCTimeCell.self, indexPath)
        let arr = isLight ? lightTimes : nightTimes
        cell?.updateUI(arr[indexPath.row])
        cell?.handler = { [weak self] in
            self?.timeAction(indexPath.row)
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 32.0 - 45.0) / 4.0
        return CGSize(width: width, height: 30.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if count <= 8 {
            return UICollectionReusableView()
        }else {
            let footer = collectionView
                .dzy_dequeueFooter(LPtExpRCTimeMoreFooterView.self, indexPath)
            footer?.updateUI(isOpen)
            footer?.handler = { [weak self] in
                self?.openAction()
            }
            return footer!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return count <= 8 ? .zero : CGSize(width: collectionView.dzy_w, height: 45.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 9.0, bottom: 0, right: 9.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9.0
    }
}
