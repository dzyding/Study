//
//  SetCoachView.swift
//  PPBody
//
//  Created by Mike on 2018/6/22.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class SetCoachView: UIView {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var idCardTF: UITextField!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityLB: UILabel!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var gymTF: UITextField!


    func getDicData() -> [String: String]? {
        if (nameTF.text?.isEmpty)! {
            ToolClass.showToast("请输入姓名", .Failure)
            return nil
        }
        if !ToolClass.checkIDCard(idCardTF.text!) {
            ToolClass.showToast("请输入身份证号码", .Failure)
            return nil
        }

        if (timeLB.text?.isEmpty)! {
            ToolClass.showToast("请选择入行时间", .Failure)
            return nil
        }
        if (gymTF.text?.isEmpty)! {
            ToolClass.showToast("请输入现任健身房", .Failure)
            return nil
        }
        return ["realname": nameTF.text!, "idCard": idCardTF.text!, "city": self.cityLB.text!, "entryTime": timeLB.text!, "gym": gymTF.text!]
    }
    
    @objc func tapView(sender: UITapGestureRecognizer) {

        if sender.view == self.cityView {
            let vc = CityVC()
            vc.delegate = self
            ToolClass.controller2(view: self)?.navigationController?.pushViewController(vc, animated: true)
        }else if sender.view == self.timeView
        {
            let former = DateFormatter()
            former.dateFormat = "yyyy-MM-dd"
            let alert = ActionSheetDatePicker.init(title: "请入行时间", datePickerMode: .date, selectedDate: Date(), doneBlock: { (picker, selectedDate, origin) in
                
                self.timeLB.text = former.string(from: selectedDate as! Date)
            }, cancel: { (picker) in
                
            }, origin: sender.view)
            
            alert?.minimumDate = Date().set(year: Date().year - 40, month: nil, day: nil, hour: nil, minute: nil, second: nil, tz: nil)
            alert?.maximumDate = Date()
            
            
            ToolClass.setActionSheetStyle(alert: alert!)
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapCity = UITapGestureRecognizer.init(target: self, action: #selector(tapView))
        self.cityView.addGestureRecognizer(tapCity)
        
        let tapTime = UITapGestureRecognizer.init(target: self, action: #selector(tapView))
        self.timeView.addGestureRecognizer(tapTime)

        nameTF.setPlaceholderColor(Text1Color)
        idCardTF.setPlaceholderColor(Text1Color)
        gymTF.setPlaceholderColor(Text1Color)
    }
    
    class func instanceFromNib() -> SetCoachView {
        return UINib(nibName: "SetCoachView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SetCoachView
    }
}

extension SetCoachView:CitySelectDelegate
{
    func selectCity(_ city: String) {
        self.cityLB.text = city
    }
}
