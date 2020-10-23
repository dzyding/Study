//
//  CoachAddCourseVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/26.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SpinKit

class CoachAddCourseVC: BaseVC {
    @IBOutlet weak var lblTimeResult: UILabel!
    
    @IBOutlet weak var btnEnsure: UIButton!
    @IBOutlet weak var okBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var lblTimeRange: UILabel!
    @IBOutlet weak var lblTimeSelect: UILabel!
    @IBOutlet weak var viewTimeRangeSelect: UIView!
    @IBOutlet weak var viewTimeSelect: UIView!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var viewSelectCourse: UIView!
    @IBOutlet weak var viewSelectStudent: UIView!
    
    @IBOutlet weak var lblStudent: UILabel!
    @IBOutlet weak var courseTF: UITextField!
    
    
    var timgLineList = [String]()//时间线列表
    
    var timeStr:String?
    var timeRangeStr:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "课程安排"
        
        self.courseTF.attributedPlaceholder = NSAttributedString(string: "（选填）输入课程内容",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        
        let tapSelectStudent = UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:)))
        viewSelectStudent.addGestureRecognizer(tapSelectStudent)
        
        let tapSelectCourse = UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:)))
        viewSelectCourse.addGestureRecognizer(tapSelectCourse)
        
        let tapSelectTime = UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:)))
        viewTimeSelect.addGestureRecognizer(tapSelectTime)
        
        let tapSelectTimeRange = UITapGestureRecognizer.init(target: self, action: #selector(tapView(tap:)))
        viewTimeRangeSelect.addGestureRecognizer(tapSelectTimeRange)
        
    }
    
    
    @IBAction func btnEnsureClick(_ sender: UIButton) {
        if dataDic.stringValue("uid") == nil,
            dataDic.stringValue("mobile") == nil
        {
            ToolClass.showToast("请将课程指向某学员", .Failure)
            return
        }
        
        guard let timeStr = timeStr,
            let timeRangeStr = timeRangeStr,
            timeStr.count > 0,
            timeRangeStr.count > 0
        else {
            ToolClass.showToast("请选择课程安排的时间", .Failure)
            return
        }

        dataDic["day"] = timeStr + " " + timeRangeStr.components(separatedBy: "-")[0] + ":00"
        dataDic["time"] = timeRangeStr
        
        if let text = courseTF.text,
            text.count > 0
        {
            dataDic["content"] = text
        }
        
        sender.setTitle("", for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.okBtnWidth.constant = 50
            self.view.layoutIfNeeded()
        }) { (finish) in
            if finish {
                let spinkit = RTSpinKitView(style: RTSpinKitViewStyle.styleArc, color: BackgroundColor)
                spinkit?.spinnerSize = 35
                sender.addSubview(spinkit!)
                spinkit?.snp.makeConstraints({ (make) in
                    make.center.equalToSuperview()
                })
                
                spinkit?.startAnimating()
                self.addCourseAPI()
            }
        }
    }
    
    
    @IBAction func tapCourseAction(_ sender: UIButton) {
        let vc = PrivateTrainVC()
        vc.title = "选择课程计划"
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapView(tap: UITapGestureRecognizer) {
        if tap.view == viewSelectStudent {
            let vc = CoachSelectStudentVC()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
    
        }
        else if tap.view == viewSelectCourse {
           let vc = PrivateTrainVC()
            vc.title = "选择课程计划"
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tap.view == viewTimeSelect {
            let alert = ActionSheetDatePicker.init(title: "请选择日期", datePickerMode: .date, selectedDate: Date.init(), doneBlock: { (picker, selecteValue, origin) in
                let dateFormat = DateFormatter.init()
                dateFormat.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormat.string(from: selecteValue as! Date)
                self.timeStr = dateString
                self.getTimeLineListAPI()
                self.lblTimeRange.text = nil
                self.timeRangeStr = ""
                self.lblTimeSelect.text = self.timeStr
                self.lblTimeResult.text = "选择时间：" + self.timeStr! + "     "
                
                self.lblTimeRange.text = "时间规划中..."
                
            }, cancel: { (picker) in
                
            }, origin: tap.view)
            ToolClass.setActionSheetStyle(alert: alert!)
        }
        else if tap.view == viewTimeRangeSelect {
            if self.timeStr == "" {
                ToolClass.showToast("请先选择日期", .Failure)
                return
            }
            
            if self.lblTimeRange.text != "待选择"
            {
                let alert = ActionSheetStringPicker.init(title: "请选择时间范围", rows: self.timgLineList, initialSelection: 0, doneBlock: { (picker, selectIndex, selectValue) in
                    self.timeRangeStr = selectValue as? String
                    if self.timeRangeStr != nil
                    {
                        self.lblTimeRange.text = self.timeRangeStr
                        self.lblTimeResult.text = "选择时间：" + self.timeStr! + "     " +  self.timeRangeStr!
                    }
                    
                }, cancel: { (picker) in
                    
                }, origin: tap.view)
                ToolClass.setActionSheetStyle(alert: alert!)
            }

        }
        
    }
    
    //时间线
    func getTimeLineListAPI() {
        let request = BaseRequest()
        request.url = BaseURL.CourseTime
        request.dic["day"] = timeStr
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                self.lblTimeRange.text = "时间规划冲突，请重新选择日期"
                return
            }
            self.lblTimeRange.text = "时间规划完毕，请点击"

            let listData = data?["timeList"] as! Array<String>
            self.timgLineList = listData
        }
    }
    
    func addCourseAPI()
    {
        let request = BaseRequest()
        request.url = BaseURL.AddCourse
        request.dic = self.dataDic as! [String:String]
        request.isUser = true
        request.start { (data, error) in
            
            guard error == nil else
            {
                //执行错误信息
                self.btnEnsure.isEnabled = true
                self.btnEnsure.setTitle("确认", for: .normal)
                self.btnEnsure.subviews.last?.removeFromSuperview()
                UIView.animate(withDuration: 0.25, animations: {
                    self.okBtnWidth.constant = 295
                    self.view.layoutIfNeeded()
                })
                ToolClass.showToast(error!, .Failure)
                return
            }
            ToolClass.showToast("加课成功", .Success)
            
            NotificationCenter.default.post(name: Config.Notify_AddCourseData, object: nil, userInfo:["day":self.timeStr ?? ""])
            ToolClass.dispatchAfter(after: 1, handler: {
                self.navigationController?.popViewController(animated: true)

            })
   
        }
    }

}

extension CoachAddCourseVC: CoachSelectStudentDelegate,PrivateTrainSelectPlanDelegate
{
    func selectStudent(_ user: [String : Any]) {
        for (k,v) in user{
            self.dataDic[k] = v
        }
        
        if let mobile = user["mobile"] as? String
        {
            self.lblStudent.text = user["name"] as! String + " " + mobile
        }else{
            self.lblStudent.text = user["nickname"] as? String
        }
        self.lblStudent.textColor = UIColor.white
    }
    
    func selectMotionPlan(_ plan: [String : Any]) {
        self.dataDic["planCode"] = plan["code"] as! String
        self.courseTF.text = plan["name"] as? String
        self.courseTF.isEnabled = false
    }
    
}
