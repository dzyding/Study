//
//  ConsultVC.swift
//  YJF
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class ConsultVC: BaseVC {

    @IBOutlet weak var topStackView: UIStackView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    
    private var list: [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTopUI()
        listApi()
    }
    
    @objc private func titleAction(_ btn: UIButton) {
        guard let title = list[btn.tag].stringValue("title"),
            let cId = list[btn.tag].intValue("id")
        else {return}
        let vc = WkWebVC(.consult(cId: cId, title: title))
        dzy_push(vc)
    }
    
    private func funtypeAction(_ type: FunType) {
        switch type {
        case .loans,
             .buyCompute,
             .sellCompute:
            let vc = CalculatorVC(type)
            dzy_push(vc)
        case .commonAns:
            let vc = CommonAnsVC()
            dzy_push(vc)
        case .smartQA:
            let vc = SmartQAVC()
            dzy_push(vc)
        default:
            break
        }
    }
    
    private func setTopUI() {
        let arr: [(String, String, FunType)] = [
            ("常见问题", "consult_func_cjwt", .commonAns),
            ("智能问答", "consult_func_znwd", .smartQA),
            ("贷款计算", "home_fun_dkjs", .loans),
            ("买房税费计算", "home_fun_buy", .buyCompute),
            ("卖房税费计算", "home_fun_sell", .sellCompute)
        ]
        
        arr.forEach { (model) in
            let view = HomeTableHeaderBtnView
                .initFromNib(HomeTableHeaderBtnView.self)
            view.updateUI(model)
            view.handler = { [unowned self] type in
                self.funtypeAction(type)
            }
            topStackView.addArrangedSubview(view)
        }
    }
    
    private func setBottomUI() {
        list.enumerated().forEach { (index, data) in
            let view = getCellView(data, index: index)
            bottomStackView.addArrangedSubview(view)
        }
    }

    private func getCellView(_ data: [String : Any], index: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 54))
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = data.stringValue("title")
        label.font = dzy_Font(14)
        label.textColor = Font_Dark
        view.addSubview(label)
        
        let line = UIView()
        line.backgroundColor = dzy_HexColor(0xe5e5e5)
        view.addSubview(line)
        
        let btn = UIButton(type: .custom)
        btn.tag = index
        btn.addTarget(
            self, action: #selector(titleAction(_:)), for: .touchUpInside
        )
        view.addSubview(btn)
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(18)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.height.equalTo(1)
            make.bottom.equalTo(0)
        }
        
        btn.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(UIEdgeInsets.zero)
        }
        
        view.snp.makeConstraints { (make) in
            make.height.equalTo(54)
        }
        return view
    }
    
    //    MARK: - api
    private func listApi() {
        let request = BaseRequest()
        request.url = BaseURL.consultList
        request.dzy_start { (data, _) in
            self.list = data?.arrValue("list") ?? []
            self.setBottomUI()
        }
    }
}
