//
//  FunctionView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/10.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class FunctionView: UIView {
    
    @IBOutlet weak var collectionview: UICollectionView!
    var reviewStatus = NSNumber.init()//审核状态
    
    var dataArr:[[String:String]]?

    var userArr = [
        ["icon":"personal_icon_fb", "name":"我的发布"],
        ["icon":"personal_icon_bl", "name":"我的部落"],
        ["icon":"personal_icon_jhk", "name":"计划库"],
        ["icon":"personal_icon_dzk", "name":"动作库"],
        ["icon":"personal_icon_kc", "name":"我的课程"],
        ["icon":"personal_icon_sc", "name":"我的收藏"],
        ["icon":"personal_icon_xh", "name":"我的喜欢"],
        ["icon":"personal_icon_sz", "name":"设置"]
    ]
    
    var coachArr = [
        ["icon":"personal_icon_fb", "name":"我的发布"],
        ["icon":"personal_icon_bl", "name":"我的部落"],
        ["icon":"personal_icon_jhk", "name":"计划库"],
        ["icon":"personal_icon_dzk", "name":"动作库"],
        ["icon":"personal_icon_kc", "name":"课程排期"],
        ["icon":"personal_icon_sc", "name":"我的收藏"],
        ["icon":"personal_icon_xh", "name":"我的喜欢"],
        ["icon":"personal_icon_sz", "name":"设置"]
    ]
    
    class func instanceFromNib() -> FunctionView {
        return UINib(nibName: "FunctionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FunctionView
    }
    
    override func awakeFromNib() {
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.dzy_registerCellFromNib(FunctionCell.self)
        if DataManager.isCoach() {
            dataArr = coachArr
        }else{
            dataArr = userArr
        }
        //查看教练审核状态
        getApplyCoachStatus()
    }
    
    func getApplyCoachStatus() {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.ApplyCoachStatus
        request.start { (data, error) in
            guard error == nil else
            {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            guard let result = (data?["review"]) else { return }
            self.reviewStatus = result as? NSNumber ?? -1
            //测试
//            self.reviewStatus = -1
        }
    }
    
    func authCoach()
    {
        let vc : UIViewController
        if self.reviewStatus != 10 {
            vc = CoachCertifyVC()
        }
        else {
            vc = CoachCertifyStatusVC()
            let vc = vc as! CoachCertifyStatusVC
            vc.statusType = self.reviewStatus
        }
        let parent = ToolClass.controller2(view: self)
        parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    MARK: - api
    private func getCoachTribe(_ complete: @escaping ([String : Any]?)->()) {
        let request = BaseRequest()
        request.isUser = true
        request.url = BaseURL.MyTribe
        request.start { (data, error) in
            guard error == nil else {
                //执行错误信息
                ToolClass.showToast(error!, .Failure)
                return
            }
            complete(data?.arrValue("list")?.first)
        }
    }
}

extension FunctionView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(FunctionCell.self, indexPath)
        cell?.setData(dataArr![indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dic = dataArr![indexPath.row]
        let title = dic["name"]
        let parent = ToolClass.controller2(view: self)
        switch title {
        case "我的发布":
            let vc = MyPublicVC()
            parent?.dzy_push(vc)
        case "我的喜欢":
            let vc = MyLikeVC()
            parent?.dzy_push(vc)
        case "我的收藏":
            let vc = MyCollectVC()
            parent?.dzy_push(vc)
        case "我的课程":
            let vc = StudentCourseVC()
            parent?.dzy_push(vc)
        case "设置":
            let vc = SettingVC()
            parent?.dzy_push(vc)
        case "课程排期":
            let vc = CoachCourseVC()
            parent?.dzy_push(vc)
        case "动作库":
            let vc = MyMotionLibraryVC()
            parent?.dzy_push(vc)
        case "计划库":
            let vc = PlanListVC()
            parent?.dzy_push(vc)
        case "我的部落":
            if DataManager.isCoach() {
                getCoachTribe { (data) in
                    if let ctid = data?.stringValue("ctid"),
                        let name = data?.stringValue("name")
                    {
                        let vc = TribeTrendsVC()
                        vc.ctid = ctid
                        vc.title = name
                        parent?.dzy_push(vc)
                    }else {
                        ToolClass.showToast("您暂无部落", .Failure)
                    }
                }
            }else{
                let vc = MineTribeListVC()
                parent?.dzy_push(vc)
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 4 * 16) / 4.0
        return CGSize(width: width, height: 80)
    }
}
