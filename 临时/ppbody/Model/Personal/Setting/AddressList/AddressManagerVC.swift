//
//  AddressManagerVC.swift
//  PPBody
//
//  Created by edz on 2019/11/11.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

enum AddressManagerType {
    case new
    case edit
}

class AddressManagerVC: BaseVC {
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var regionTF: UITextField!
    
    @IBOutlet weak var addressTF: UITextField!
    
    @IBOutlet weak var defaultSW: UISwitch!
    
    @IBOutlet weak var deleteBtn: UIButton!
    /// 编辑地址的时候使用
    var old: [String : Any]?
    /// 地区
    private var region = ""
    
    private let type: AddressManagerType
    
    init(_ type: AddressManagerType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [nameTF, phoneTF, regionTF, addressTF].forEach { (tf) in
            let str = tf?.placeholder ?? ""
            let color = RGBA(r: 255.0, g: 255.0, b: 255.0, a: 0.45)
            let arrStr = NSMutableAttributedString(
                string: str,
                attributes: [
                    NSAttributedString.Key.font : dzy_Font(13),
                    NSAttributedString.Key.foregroundColor : color
            ])
            tf?.attributedPlaceholder = arrStr
        }
        switch type {
        case .new:
            navigationItem.title = "添加地址"
        case .edit:
            deleteBtn.isHidden = false
            navigationItem.title = "编辑地址"
            initUI()
        }
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    private func initUI() {
        guard let address = old else {return}
        nameTF.text = address.stringValue("name")
        phoneTF.text = address.stringValue("mobile")
        region = address.stringValue("area") ?? ""
        updateRegionText()
        addressTF.text = address.stringValue("address")
        defaultSW.isOn = address.intValue("def") == 1
        pcrView.initUI(region)
    }
    
//    MARK: - 删除
    @IBAction func deleteAction(_ sender: Any) {
        guard let addressId = old?.intValue("id") else {return}
        deleteApi(addressId)
    }
    
//    MARK: - 保存
    @objc private func saveAction() {
        guard let name = nameTF.text, name.count > 0 else {
            ToolClass.showToast("请输入姓名", .Failure)
            return
        }
        guard let mobile = phoneTF.text, mobile.count > 0 else {
            ToolClass.showToast("请输入手机号", .Failure)
            return
        }
        guard region.count > 0 else {
            ToolClass.showToast("请选择地区", .Failure)
            return
        }
        guard let address = addressTF.text, address.count > 0 else {
            ToolClass.showToast("请输入详细地址", .Failure)
            return
        }
        var dic: [String : String] = [
            "name" : name,
            "mobile" : mobile,
            "area" : region,
            "address" : address,
            "def" : defaultSW.isOn ? "1" : "0"
        ]
        if type == .edit,
            let addressId = old?.intValue("id")
        {
            dic["addressId"] = "\(addressId)"
        }
        editApi(dic)
    }
    
    @IBAction func regionAction(_ sender: UIButton) {
        popView.show()
    }
    
//    MARK: - 根据 region 信息显示信息
    private func updateRegionText() {
        let arr = region.components(separatedBy: " ")
        guard arr.count == 3 else {
            ToolClass.showToast("错误的区域信息", .Failure)
            return
        }
        if arr[0] == arr[1] {
            regionTF.text = arr[1] + arr[2]
        }else {
            regionTF.text = arr.joined()
        }
    }
    
//    MARK: - api
    private func editApi(_ dic: [String : String]) {
        let request = BaseRequest()
        request.url = BaseURL.EditAddress
        request.dic = dic
        request.isUser = true
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                ToolClass.showToast("保存成功", .Success)
                NotificationCenter.default.post(
                    name: Config.Notify_RefreshAddressList,
                    object: nil)
                self.dzy_delayPop(1)
            }
        }
    }
    
    private func deleteApi(_ addressId: Int) {
        let request = BaseRequest()
        request.url = BaseURL.DeleteAddress
        request.dic = ["addressId" : "\(addressId)"]
        request.start { (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if data != nil {
                ToolClass.showToast("删除成功", .Success)
                NotificationCenter.default.post(
                    name: Config.Notify_RefreshAddressList,
                    object: nil)
                self.dzy_delayPop(1)
            }
        }
    }
    
    //    MARK: - 懒加载
    private lazy var rightBtn: UIBarButtonItem = {
        let btn = DzySafeBtn(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(dzy_HexColor(0xF8E71C), for: .normal)
        btn.titleLabel?.font = dzy_Font(12)
        btn.addTarget(self,
                      action: #selector(saveAction),
                      for: .touchUpInside)
        btn.enabledTime = 1
        return UIBarButtonItem(customView: btn)
    }()
    
    private lazy var pcrView: AddressPCRView = {
        let view = AddressPCRView.initFromNib()
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 550)
        view.delegate = self
        return view
    }()
    
    private lazy var popView = DzyPopView(.POP_bottom, viewBlock: pcrView)
}

extension AddressManagerVC: AddressPCRViewDelegate {
    func pcrView(_ pcrView: AddressPCRView,
                 didSelectAddress str: String)
    {
        region = str
        updateRegionText()
    }
}
