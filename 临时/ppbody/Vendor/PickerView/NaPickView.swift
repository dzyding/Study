//
//  ZHYPickView.swift
//  pickView
//
//  Created by Nathan on 2016/11/28.
//  Copyright © 2016年 MYS. All rights reserved.
//


enum PickViewType {
    case PickViewType_Normal
    case PickViewType_Data
}


import UIKit

class NaPickView: UIView,UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dataSourceArr:Array<Any> = []
    
        var componentsBlock:((Array<String>) -> ())?

    var pickViewType: PickViewType = .PickViewType_Normal
        
    fileprivate var selectComponts: (Array<String>) = []
    
    init(frame: CGRect,dataSourceArr:Array<Any>) {
        super.init(frame: frame)
        self.dataSourceArr = dataSourceArr
        backgroundColor = UIColor.ColorHex("0x000000").withAlphaComponent(0.4)
        setUpPickView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showPickView(dataSourceArr:Array<Any>,componentBlock:@escaping (Array<String>) -> ()){
        let rect: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let pickView: NaPickView = NaPickView(frame: rect,dataSourceArr:dataSourceArr)
        pickView.componentsBlock = componentBlock
        UIApplication.shared.keyWindow?.addSubview(pickView)
    }
    
    // 初始化视图
    func setUpPickView() {
        addSubview(self.bgView)
        self.bgView.addSubview(self.cancelButton)
        self.bgView.addSubview(self.certainButton)
        self.bgView.addSubview(self.pickView)
        self.selectComponts.append(self.dataSourceArr.first as! String? ?? "ZHY")
    }
    
    // Mark -- UIPickerViewDataSource
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 设置列数
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 5
//    }
    
    // 设置行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSourceArr.count
    }
    
    // 设置每行具体内容（titleForRow 和 viewForRow 二者实现其一即可）
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataSourceArr[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat{
        return 45
    }
    
    
    // 选中行的操作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            self.selectComponts = []
            let temp:String  = self.dataSourceArr[row] as! String
            self.selectComponts.append(temp)
        }
    }
    
    //usingSpringWithDamping :弹簧动画的阻尼值，也就是相当于摩擦力的大小，该属性的值从0.0到1.0之间，越靠近0，阻尼越小，弹动的幅度越大，反之阻尼越大，弹动的幅度越小，如果大道一定程度，会出现弹不动的情况。
    //initialSpringVelocity :弹簧动画的速率，或者说是动力。值越小弹簧的动力越小，弹簧拉伸的幅度越小，反之动力越大，弹簧拉伸的幅度越大。这里需要注意的是，如果设置为0，表示忽略该属性，由动画持续时间和阻尼计算动画的效果。
    
    // 背景视图
    lazy var bgView: UIView = {
        let y:CGFloat = UIScreen.main.bounds.size.height - 250
        let rect = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 250)
        let bgView = UIView(frame:rect)
        UIView.animate(withDuration: 0.25, delay: 0.3, options: .transitionFlipFromBottom , animations: {
            bgView.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: 290)
        }, completion: { (flase) in
        })
        bgView.backgroundColor = UIColor.ColorHex("0x000000")
        return bgView
    }()
    
    
    // 取消
    lazy var cancelButton: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 55, height: 50)
        let cancelButton = UIButton(frame: rect)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(NaPickView.cancelButtonAction), for: .touchUpInside)
        return cancelButton
    }()
    
    // 完成
    lazy var certainButton: UIButton = {
        let x:CGFloat = self.frame.size.width - 55
        let rect = CGRect(x: x, y: self.cancelButton.frame.origin.y, width: 55, height: 50)
        let certainButton = UIButton(frame: rect)
        certainButton.setTitle("完成", for: .normal)
        certainButton.setTitleColor(UIColor.white, for: .normal)
        certainButton.addTarget(self, action: #selector(NaPickView.certainButtonAction), for: .touchUpInside)
        return certainButton
    }()
    
    
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
        self.componentsBlock!(self.selectComponts)
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
        self.removeFromSuperview()
    }
    
    
    
}
