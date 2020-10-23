//
//  LocationClassDetailVC.swift
//  PPBody
//
//  Created by edz on 2019/10/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LocationGClassDetailVC: BaseVC, AttPriceProtocol {

    @IBOutlet weak var placeHolderView: UIView!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var titleLB: UILabel!
    
    @IBOutlet weak var groupPriceLB: UILabel!
    
    @IBOutlet weak var shopPriceLB: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var datas: [String] = [
        "促进澳门过",
        "第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！",
        "第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！",
        "一看氛围，就知道高手非常多，与高手交流让我热血沸腾，瞬间就有了锻炼的激情，当初选择这家的主要原因是因为位置离我家比较近，接待我们的工作人员很热情，通过接触感觉教练们都很专业，整体来说很不错。",
        "第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！",
        "促进澳门过",
        "第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！",
        "第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！",
        "一看氛围，就知道高手非常多，与高手交流让我热血沸腾，瞬间就有了锻炼的激情，当初选择这家的主要原因是因为位置离我家比较近，接待我们的工作人员很热情，通过接触感觉教练们都很专业，整体来说很不错。",
        "第一次过来游泳，感觉水质蛮好，真的强力推荐。服务特别热情，小姐姐人都挺好，服务质量超奈斯！！！"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dzy_registerCellNib(LGymEvaluateCell.self)
        groupPriceLB.attributedText = attPriceStr(16.8)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?
            .setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?
            .setNavigationBarHidden(false, animated: false)
    }

    @IBAction func backAction(_ sender: Any) {
        dzy_pop()
    }
    
//    MARK: - 懒加载
    private lazy var headerView: LClassHeaderView = {
        let view = LClassHeaderView.initFromNib()
        view.initUI()
        view.delegate = self
        return view
    }()
    
    private lazy var keysFooterView: UIView = {
        let sframe = CGRect(x: 16,
                            y: 0,
                            width: ScreenWidth - 32,
                            height: 27)
        let source = VarietyLabelView([
            "泳池干净(31)",
            "私教专业 服务热情 (19)",
            "交通便利(21)",
            "环境优雅(46)",
            "水干净(36)",
            "体验很棒(33)"
        ], frame: sframe)
        source.font = dzy_Font(12)
        source.height = 27
        source.cRadius = 13.5
        source.xPadding = 9
        source.yPadding = 15
        source.initSubViews()
        let height = source.frame.height
        
        let vframe = CGRect(x: 0,
                            y: 0,
                            width: ScreenWidth,
                            height: height)
        let view = UIView(frame: vframe)
        view.backgroundColor = .clear
        view.addSubview(source)
        return view
    }()
}

extension LocationGClassDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        default:
            return datas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(LGymEvaluateCell.self)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 294
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 920.0
        }else {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headerView
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return keysFooterView
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return keysFooterView.frame.height
        }else {
            return 0.1
        }
    }
}

extension LocationGClassDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.dzy_ofy >= 100 {
            titleView.backgroundColor = dzy_HexColor(0x232327)
            titleLB.isHidden = false
            placeHolderView.isHidden = false
        }else {
            titleView.backgroundColor = .clear
            titleLB.isHidden = true
            placeHolderView.isHidden = true
        }
    }
}

extension LocationGClassDetailVC: LClassHeaderViewDelegate {
    func headerView(_ headerView: LClassHeaderView,
                    didClickShopListBtn btn: UIButton) {
        let vc = LocationShopListVC()
        dzy_push(vc)
    }
    
    func headerView(_ headerView: LClassHeaderView,
                    didClickEvaluateListBtn btn: UIButton) {
//        let vc = LocationEvaluateListVC()
//        dzy_push(vc)
    }
}
