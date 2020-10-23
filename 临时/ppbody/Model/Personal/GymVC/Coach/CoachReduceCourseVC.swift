//
//  CoachReduceCourseVC.swift
//  PPBody
//
//  Created by edz on 2019/7/27.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CoachReduceCourseVC: BaseVC, CustomBackProtocol {
    
    private let code: String
    
    private let data: [String : Any]

    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var reduceBtn: UIButton!
    
    @IBOutlet weak var sexIV: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private var list: [[String : Any]] = []
    
    init(_ data: [String : Any], code: String) {
        self.data = data
        self.code = code
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "课程核销"
        dzy_removeChildVCs([QRScanCodeVC.self])
        initUI()
    }
    
    private func initUI() {
        nameLB.text = "• " + (data.stringValue("name") ?? "")
        let imgName = (data.intValue("sex") == 10) ?
            "sex_man" : "sex_woman"
        sexIV.image = UIImage(named: imgName)
        list = data.arrValue("list") ?? []
        for (index, temp) in list.enumerated() {
            var course = temp
            course["isSelected"] = false
            let cView = CoachReduceCourseView
                .initFromNib(CoachReduceCourseView.self)
            cView.delegate = self
            cView.updateUI(course, row: index)
            cView.snp.makeConstraints { (make) in
                make.height.equalTo(60)
            }
            stackView.addArrangedSubview(cView)
        }
    }
    
    @IBAction func reduceAction(_ sender: UIButton) {
        if let course = list.first(where: {$0.boolValue("isSelected") == true}),
            let classId = course.intValue("classId")
        {
            let dic = [
                "classId" : "\(classId)",
                "reserveId" : "\(data.intValue("reserveId") ?? 0)",
                "code" : code
            ]
            alertView.updateUI(course.stringValue("name") ?? "")
            alertView.handler = { [weak self] in
                self?.popView.hide()
                self?.reduceCourseApi(dic)
            }
            popView.show()
        }else {
            ToolClass.showToast("请选择核销课类型", .Failure)
        }
    }
    
    //    MARK: - api
    private func reduceCourseApi(_ dic: [String : String]) {
        guard let mid = data.stringValue("mid"),
            let pid = data.stringValue("pid")
        else {return}
        let request = BaseRequest()
        request.url = BaseURL.ReduceCourse
        request.dic = dic
        request.setPtId(pid)
        request.setMemberId(mid)
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("核销成功", .Success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.dzy_pop()
            })
        }
    }
    
    //    MARK: - 懒加载
    private lazy var popView: DzyPopView = {
        let view = DzyPopView(.POP_center_above)
        view.updateSourceView(alertView)
        return view
    }()
    
    private lazy var alertView = CoachReduceCourseAlertView
        .initFromNib(CoachReduceCourseAlertView.self)
}

extension CoachReduceCourseVC: CoachReduceCourseViewDelegate {
    func courseView(_ courseView: CoachReduceCourseView, didSelectedRow row: Int) {
        guard list.count == stackView.arrangedSubviews.count else {
            ToolClass.showToast("数据错误", .Failure)
            return
        }
        (0..<list.count).forEach { (index) in
            list[index]["isSelected"] = false
        }
        list[row]["isSelected"] = true
        stackView.arrangedSubviews.enumerated().forEach { (index, v) in
            if let v = v as? CoachReduceCourseView {
                v.updateUI(list[index], row: index)
            }
        }
    }
}
