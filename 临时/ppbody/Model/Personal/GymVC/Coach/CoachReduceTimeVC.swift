//
//  CoachReduceTimeVC.swift
//  PPBody
//
//  Created by edz on 2019/5/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceTimeVC: BaseVC {
    
    weak var settingVC: CoachReduceSettingVC?

    @IBOutlet private weak var tableView: UITableView!
    // 可用时间段
    private var canUsed: [[Int]] = []
    
    private var datas:[(Int, Int)] = []
    
    private lazy var popView: DzyPopView = DzyPopView(.POP_bottom)
    
    private lazy var picker: CoachReduceTimePicker = {
        let timePicker =
            CoachReduceTimePicker.initFromNib(CoachReduceTimePicker.self)
        timePicker.delegate = self
        timePicker.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 205)
        return timePicker
    }()
    
    init(_ datas: [(Int, Int)]) {
        self.datas = datas
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "可预约时间段"
        tableView.dzy_registerCellNib(CoachReduceTimeCell.self)
        
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settingVC?.updateTimes(datas)
    }
    
    private func setUI() {
        var temp: [Int] = []
        (6...24).forEach { (time) in
            let hour = time * 60
            temp.append(hour)
            if time != 24 {
                temp.append(hour + 30)
            }
        }
        canUsed.append(temp)
        updateTimes()
        popView.updateSourceView(picker)
    }
    
    private func updateTimes() {
        datas.forEach { (start, end) in
            if let index = canUsed.firstIndex(where: {$0.contains(start) && $0.contains(end)}) {
                let tempArr = canUsed[index]
                var startArr = [Int]()
                var endArr = [Int]()
                if let startIndex = tempArr.firstIndex(where: {$0 == start}) {
                    startArr = [Int](tempArr[...startIndex])
                }
                if let endIndex = tempArr.firstIndex(where: {$0 == end}) {
                    endArr = [Int](tempArr[endIndex...])
                }
                canUsed.remove(at: index)
                canUsed.insert(endArr, at: Int(index))
                canUsed.insert(startArr, at: Int(index))
            }
        }
        // 删除只有一个元素的，它已经不是时间段了
        canUsed.removeAll(where: {$0.count == 1})
        picker.updateUI(canUsed)
    }
    
    //    MARK: - 新增
    private func newAction() {
        if canUsed.isEmpty {
            ToolClass.showToast("无可用时间段", .Failure)
        }else {
            popView.show()
        }
    }
    
    //    MARK: - 删除
    private func delAction(_ row: Int) {
        let alert = dzy_normalAlert("提示", msg: "您确定要删除么.?", sureClick: { (_) in
            self.delActionNext(row)
        }, cancelClick: nil)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func delActionNext(_ row: Int) {
        let time = datas[row]
        datas.remove(at: row)
        tableView.reloadData()
        addNewTimeArr(time)
        canUsed.sort(by: {($0.first ?? 0) < ($1.first ?? 0)})
        picker.updateUI(canUsed)
    }
    
    // 将删除的时间段加回可用时间段
    private func addNewTimeArr(_ time: (Int, Int)) {
        var arr = [Int]()
        var temp = time.0
        while temp <= time.1 {
            arr.append(temp)
            temp += 30
        }
        // 在另外两段的中间
        if let findex = canUsed.firstIndex(where: {$0.last == time.0}),
            let sindex = canUsed.firstIndex(where: {$0.first == time.1}),
            sindex - findex == 1
        {
            var farr = canUsed[findex]
            farr.removeLast()
            var sarr = canUsed[sindex]
            sarr.removeFirst()
            canUsed.remove(at: sindex)
            canUsed.remove(at: findex)
            canUsed.insert(farr + arr + sarr, at: findex)
        // 接在另一段之后
        }else if let index = canUsed.firstIndex(where: {$0.last == time.0}) {
            var tempArr = canUsed[index]
            tempArr.removeLast()
            canUsed.remove(at: index)
            canUsed.insert(tempArr + arr, at: index)
        // 接在另一段之前
        }else if let index = canUsed.firstIndex(where: {$0.first == time.1}) {
            var tempArr = canUsed[index]
            tempArr.removeFirst()
            canUsed.remove(at: index)
            canUsed.insert(arr + tempArr, at: index)
        }else {
            canUsed.append(arr)
        }
    }

    //    MARK: - 懒加载
    private lazy var footerView: CoachReduceTimeFooter = {
        let footer = CoachReduceTimeFooter.initFromNib(CoachReduceTimeFooter.self)
        footer.handler = { [weak self] in
            self?.newAction()
        }
        return footer
    }()
}

extension CoachReduceTimeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dzy_dequeueReusableCell(CoachReduceTimeCell.self)
        cell?.delHandler = { [weak self] in
            self?.delAction(indexPath.row)
        }
        cell?.updateUI(datas[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
}

extension CoachReduceTimeVC: CoachReduceTimePickerDelegate {
    func picker(_ picker: CoachReduceTimePicker, didSelectTime start: Int, end: Int) {
        datas.append((start, end))
        datas.sort(by: {$0.0 < $1.0})
        tableView.reloadData()
        updateTimes()
    }
}
