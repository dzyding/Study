//
//  NaDatePickerView.swift
//  WashCar
//
//  Created by Nathan_he on 2018/3/3.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation
import UIKit

class NaDatePickView: UIView,UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    var componentsBlock:((String) -> ())?
    
    var selectDate = String()
    
    let hourArr = ["0点","1点","2点","3点","4点","5点","6点","7点","8点","9点","10点","11点","12点","13点","14点","15点","16点","17点","18点","19点","20点","21点","22点","23点"]
    let minArr = ["00分","10分","20分","30分","40分","50分"]
    
    var todayArr = [String]()
    var todayHourArr = [String]()
    var todayMinArr = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ColorHex("0x000000").withAlphaComponent(0.4)
        setUpPickView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showPickView(componentBlock:@escaping (String) -> ()){
        
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let pickView: NaDatePickView = NaDatePickView(frame: rect)
        pickView.componentsBlock = componentBlock
        
        let today = Date()

        var startDay = today
        var startMin = (today.minute/10 + 2) * 10
        var startHour = today.hour
        
        if startMin > 50 {
            startHour = startHour + 1
            startMin = 0
        }
        
        if startHour > 23 {
            startDay = Date(timeInterval: 24*60*60, since: today)
            startHour = 0
        }
        
        if startMin == 0
        {
            pickView.todayMinArr = pickView.minArr
        }else{
            for i in  stride(from: startMin, to: 50, by: 10)
            {
                pickView.todayMinArr.append(String(format: "%d分", i))
            }
        }
        
        if startHour == 0
        {
            pickView.todayHourArr = pickView.hourArr
        }else{
            for i in startHour...23
            {
                pickView.todayHourArr.append(String(format: "%d时", i))
            }
        }
        
        let tomorrow = Date(timeInterval: 24*60*60, since: startDay)
        let aftertomorrow = Date(timeInterval: 2*24*60*60, since: startDay)
        
        let todayStr = String(format: "%d月%d日 %@", startDay.month,startDay.day,"今天")
        let tomorrowStr = String(format: "%d月%d日 %@", tomorrow.month,tomorrow.day,tomorrow.weekDay())
        let aftertomorrowStr = String(format: "%d月%d日 %@", aftertomorrow.month,aftertomorrow.day,aftertomorrow.weekDay())
        pickView.todayArr = [todayStr,tomorrowStr,aftertomorrowStr]
        
        pickView.selectDate = String(format: "%@ %@%@", pickView.todayArr[0],pickView.todayHourArr[0],pickView.todayMinArr[0])
        
        UIApplication.shared.keyWindow?.addSubview(pickView)
    }
    
    // 初始化视图
    func setUpPickView() {
        addSubview(self.bgView)
        self.bgView.addSubview(self.cancelButton)
        self.bgView.addSubview(self.certainButton)
        self.bgView.addSubview(self.pickView)

    }

    
    // 背景视图
    lazy var bgView: UIView = {
        let y:CGFloat = UIScreen.main.bounds.size.height - 250
        let rect = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 250)
        let bgView = UIView(frame:rect)
        UIView.animate(withDuration: 0.25, delay: 0.3, options: .transitionFlipFromBottom , animations: {
            bgView.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: 290)
        }, completion: { (flase) in
        })
        
        let line = UIView(frame: CGRect(x: 0, y: 49, width: UIScreen.main.bounds.size.width, height: CGFloat(LINE_HEIGHT)))
        line.backgroundColor = ColorLine
        bgView.addSubview(line)
        bgView.backgroundColor = UIColor.white
        return bgView
    }()
    
    
    // 取消
    lazy var cancelButton: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 55, height: 50)
        let cancelButton = UIButton(frame: rect)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(TextMainColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(NaDatePickView.cancelButtonAction), for: .touchUpInside)
        return cancelButton
    }()
    
    // 完成
    lazy var certainButton: UIButton = {
        let x:CGFloat = self.frame.size.width - 55
        let rect = CGRect(x: x, y: self.cancelButton.frame.origin.y, width: 55, height: 50)
        let certainButton = UIButton(frame: rect)
        certainButton.setTitle("确认", for: .normal)
        certainButton.setTitleColor(YellowMainColor, for: .normal)
        certainButton.addTarget(self, action: #selector(NaDatePickView.certainButtonAction), for: .touchUpInside)
        return certainButton
    }()
    
    
    // Mark -- UIPickerViewDataSource
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // 设置行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.todayArr.count
        case 1:
            if pickerView.selectedRow(inComponent: 0) == 0
            {
                return self.todayHourArr.count
            }else{
                return self.hourArr.count
            }
        case 2:
            if pickerView.selectedRow(inComponent: 0) == 0
            {
                return self.todayMinArr.count
            }else{
                return self.minArr.count
            }
        default:
            return 0
        }
    }
    
    // 设置每行具体内容（titleForRow 和 viewForRow 二者实现其一即可）
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return self.todayArr[row]
        case 1:
            if pickerView.selectedRow(inComponent: 0) == 0
            {
                return self.todayHourArr[row]
            }else{
                return self.hourArr[row]
            }
        case 2:
            if pickerView.selectedRow(inComponent: 0) == 0
            {
                return self.todayMinArr[row]
            }else{
                return self.minArr[row]
            }
        default:
            return ""
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat{
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return UIScreen.main.bounds.size.width/2
        case 1:
            return UIScreen.main.bounds.size.width/4
        case 2:
            return UIScreen.main.bounds.size.width/4
        default:
            return 0
        }
    }
    
    
    // 选中行的操作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0
        {
            pickerView.reloadAllComponents()
        }
        
        let select1 = pickerView.selectedRow(inComponent: 0)
        
        var text1,text2,text3: String
        
        text1 = self.todayArr[select1]
        
        if select1 == 0
        {
            text2 = self.todayHourArr[pickerView.selectedRow(inComponent: 1)]
            text3 = self.todayMinArr[pickerView.selectedRow(inComponent: 2)]
        }else{
            text2 = self.hourArr[pickerView.selectedRow(inComponent: 1)]
            text3 = self.minArr[pickerView.selectedRow(inComponent: 2)]
        }
        
        selectDate = String(format: "%@ %@%@", text1,text2,text3)
    }
    
    // pickView
    lazy var pickView : UIPickerView = {
        let y:CGFloat = self.cancelButton.frame.maxY
        let height:CGFloat = self.bgView.frame.size.height - self.certainButton.frame.size.height
        let rect = CGRect(x: -1, y:y, width:self.frame.size.width+2, height:height)

        let myPickerView = UIPickerView(frame: rect)
        myPickerView.backgroundColor = UIColor.white
        myPickerView.delegate = self
        myPickerView.dataSource = self
        myPickerView.showsSelectionIndicator = false
        myPickerView.selectRow(0, inComponent: 0, animated: true)
        return myPickerView
    }()
    

    // 取消
    @objc func cancelButtonAction(){
        self.removePickView()
    }
    
    // 确定
    @objc func certainButtonAction(){
        self.componentsBlock!(self.selectDate)
        self.removePickView()
    }
    
    
    func removePickView() {
        UIView.animate(withDuration: 0.25, delay: 0.3, options: .transitionFlipFromBottom , animations: {
            self.bgView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 290)
        }, completion: { (flase) in
            self.removeFromSuperview()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removePickView()
    }
    
    
    
}
