//
//  TimeTableVC.swift
//  PPBody
//
//  Created by edz on 2019/4/15.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class TimeTableVC: BaseVC {
    
    private let colors = [
        dzy_HexColor(0xF19EC2), dzy_HexColor(0x89C997),
        dzy_HexColor(0x8F82BC), dzy_HexColor(0x7ECEF4),
        dzy_HexColor(0xF8B551), dzy_HexColor(0xACD598),
        dzy_HexColor(0xC490BF), dzy_HexColor(0x8C97CB),
        dzy_HexColor(0xF19149), dzy_HexColor(0xB3D465)
    ]
    
    private let space: CGFloat = 1.0

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollLeftLC: NSLayoutConstraint!
    @IBOutlet weak var scrollBottomLC: NSLayoutConstraint!
    // 操作成功的时候进行更新视图使用
    private weak var classView: TimeTableClassView?
    
    // 课程相关 stackView
    lazy var sourceSv: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = space
        stackView.axis = .horizontal
        return stackView
    }()
    
    // 左边的周一到周天
    lazy var weakView: UIView = {
        let view = Bundle.main.loadNibNamed("TimeTableWeakView", owner: nil, options: nil)?.first as? UIView
        return view ?? UIView()
    }()
    
    // 处理过的数据
    var datas: [TimeTableModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "课程表"
        scrollView.isHidden = true
        classListApi()
    }
    
    private func setUI() {
        let xNum: Int = datas.reduce(0) {$0 + $1.times.count}
        var colorDic: [String : UIColor] = [:]
        var colorIndex: Int = 0
        if xNum == 0 {
            scrollView.isHidden = false
            return
        }
        // 所有 icon 的高度，以及左边课程 周一到周天 icon 的宽高
        let height = (scrollView.dzy_h - 101.0) / 7.0
        // 等分的比例
        let x: CGFloat = xNum >= 4 ? 4.0 : CGFloat(xNum)
        // 10.0 为左右边距 (右边其余 icon 的宽度)
        let length = (ScreenWidth - 10.0 - height - (x - 1) * space) / x
        // scrollView 的contentSize
        let contentSizeW = (length + space) * CGFloat(xNum) - space
        let contentSizeH = scrollView.dzy_h
        // 设置左边的星期视图
        setWeakView(height, height: contentSizeH)
        // 设置一个背景视图，用来做圆角
        let bgView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: contentSizeW,
            height: contentSizeH)
        )
        bgView.backgroundColor = YellowMainColor
        bgView.layer.cornerRadius = 6
        bgView.layer.borderColor = YellowMainColor.cgColor
        bgView.layer.borderWidth = 1
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        scrollView.addSubview(bgView)
        scrollView.backgroundColor = BackgroundColor
        scrollView.contentSize = CGSize(
            // 超过一个屏幕就需要 + 5
            width: (contentSizeW > ScreenWidth - 10.0 - height) ? contentSizeW + 5 : contentSizeW,
            height: contentSizeH
        )
        scrollLeftLC.constant = 5 + height - 1
        
        // 设置上面的房间名和时间
        let temp = setRoomNameAndTime(length, sizeW: contentSizeW, bgView: bgView)
        // 水平滚动，主stackView
        let sourceX:CGFloat = space
        let sourceY:CGFloat = temp.frame.maxY + space
        // 因为课程的这一块没有分割线，所以需要用 view 包一层
        let sourceBg = UIView(frame: CGRect(
            x: sourceX,
            y: sourceY,
            width: contentSizeW - sourceX,
            height: contentSizeH - sourceY)
        )
        sourceBg.backgroundColor = BackgroundColor
        bgView.addSubview(sourceBg)
        // 用来显示所有课程的 stackView
        sourceSv.frame = sourceBg.bounds
        sourceBg.addSubview(sourceSv)
        // 所有的课程
        for model in datas {
            for time in model.times {
                let vStackView = UIStackView()
                vStackView.alignment = .fill
                vStackView.distribution = .fillEqually
                vStackView.spacing = space
                vStackView.axis = .vertical
                
                let arr = model.classes[time] ?? []
                for (weak, dic) in arr.enumerated() {
                    if let dic = dic {
                        let name = dic.stringValue("name") ?? ""
                        var resultColor: UIColor = .white
                        if let color = colorDic[name] {
                            resultColor = color
                        }else {
                            resultColor = colors[colorIndex % colors.count]
                            colorDic[name] = resultColor
                            colorIndex += 1
                        }
                        let classView = TimeTableClassView.initFromNib(TimeTableClassView.self)
                        classView.updateViews(dic, week: weak + 1, color: resultColor)
                        classView.delegate = self
                        vStackView.addArrangedSubview(classView)
                    }else {
                        let emptyView = UIView()
                        emptyView.backgroundColor = .clear
                        vStackView.addArrangedSubview(emptyView)
                    }
                }
                sourceSv.addArrangedSubview(vStackView)
            }
        }
        scrollView.isHidden = false
    }
    
    private func setWeakView(_ width: CGFloat, height: CGFloat) {
        let bgView = UIView()
        bgView.backgroundColor = YellowMainColor
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        bgView.layer.borderColor = YellowMainColor.cgColor
        bgView.layer.borderWidth = 1
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(scrollView)
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        bgView.addSubview(weakView)
        weakView.snp.makeConstraints { (make) in
            make.edges.equalTo(bgView).inset(UIEdgeInsets.zero)
        }
    }
    
    private func setRoomNameAndTime(_ length: CGFloat, sizeW: CGFloat, bgView: UIView) -> UIView {
        // 上面两个 view 的高度
        let h: CGFloat = 50.0
        let originX = space
        var x = originX
        var times: [String] = []
        // 房间名
        datas.forEach { (model) in
            let width = CGFloat(model.times.count) * (length + space) - space
            let frame = CGRect(x: x, y: 0, width: width, height: h)
            let label = UILabel(frame: frame)
            label.text = model.name
            label.font = ToolClass.CustomFont(15)
            label.textColor = .white
            label.textAlignment = .center
            label.backgroundColor = BackgroundColor
            bgView.addSubview(label)
            x += (width + space)
            times += model.times
        }
        
        // 时间段
        let frame = CGRect(x: originX, y: h + space, width: sizeW - originX, height: h)
        let stackView = UIStackView(frame: frame)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = space
        stackView.axis = .horizontal
        bgView.addSubview(stackView)
        
        times.forEach { (str) in
            let arr = str.components(separatedBy: "-")
            if arr.count == 2 {
                let view = TimeTableTimeView.initFromNib(TimeTableTimeView.self)
                view.startLB.text = arr[0]
                view.endLB.text = arr[1]
                stackView.addArrangedSubview(view)
            }
        }
        return stackView
    }
    
    //    MARK: - 团课信息处理
    func dealWithClassData(_ data: [String : Any]?) {
        let list = data?.arrValue("list") ?? []
        datas = TimeTableModel.dealWithData(list)
        setUI()
    }
    
    //    MARK: - 团课信息
    func classListApi() {
        var weekNum = dzy_weekNum(Date())
        weekNum = weekNum == 1 ? 7 : weekNum - 1
        let request = BaseRequest()
        request.url = BaseURL.GroupClassList
        request.isSaasUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            self.dealWithClassData(data)
        }
    }
    
    //    MARK: - 团课预约
    func classReserveApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.ClassReserve
        request.dic = dic
        request.isSaasUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                self.classView?.reserveClassEnd()
                self.classView = nil
            }
        }
    }
}

extension TimeTableVC: TimeTableClassViewDelegate {
    
    func classView(_ classView: TimeTableClassView, didSelected btn: UIButton) {
        self.classView = classView
        // 课程信息
        let data = classView.data
        // 选择的星期几
        let sel = classView.week
        // 今天星期几
        var today = dzy_weekNum(Date())
        today = today == 1 ? 7 : today - 1
        // 限制数量
        let num   = data.intValue("reserveNum") ?? 0
        let limit = data.intValue("limit") ?? -1
        // 预约 or 取消
        let type  = data.intValue("isReserve") ?? 0
        
        let x = today <= sel ? (sel - today) : (sel + 7 - today)
        if x > 2 {
            ToolClass.showToast("只可预约今明后三天的课程", .Failure)
        }else if type == 0, limit != -1, num >= limit { // 只有预约需要判断是否名额不足
            ToolClass.showToast("剩余名额不足", .Failure)
        }else {
            let calendar = Calendar.current
            func getTimeString(_ date: Date) -> String {
                let year  = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day   = calendar.component(.day, from: date)
                return String(format: "%ld-%02ld-%02ld", year, month, day)
            }
            let now = Date()
            var component = DateComponents()
            component.day = x
            // 选择的日期
            guard let selDate = calendar.date(byAdding: component, to: now) else {return}
            // 如果是今天，判断是否已经过期
            if x == 0 {
                let hour = calendar.component(.hour, from: selDate)
                let min  = calendar.component(.minute, from: selDate)
                let selStart = data.intValue("start") ?? 0
                let currentInt = hour * 60 + min
                if currentInt > selStart {
                    ToolClass.showToast("当前预约课程已经失效", .Failure)
                    return
                }
            }
            
            let time = getTimeString(selDate)
            let groupId = classView.data.intValue("id") ?? 0
            let dic: [String : String] = [
                "groupId" : "\(groupId)",
                "reserveTime" : time,
                "type" : "\(type == 0 ? 10 : 20)"
            ]
            classReserveApi(dic)
        }
    }
    
}
