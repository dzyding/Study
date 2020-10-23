//
//  AddHousePhotoVC.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import DzyImagePicker

@objc enum AddHouseType: Int {
    case owner  //房主
    case agent  //代理人
}

class AddHousePhotoVC: BaseVC {
    
    var imgs: [[(UIImage?, String?)?]] = [
        [nil, nil],
        [nil, nil],
        [nil],
        [nil, nil]
    ]
    
    var type: AddHouseType = .owner
    
    var currentIndex: (Int, Int)?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.dzy_registerCellNib(AddHousePhotoCell.self)
    }
    
    //    MARK: - 撤销的重新提交时，初始化视图
    func initUI(_ cert: [String : Any]) {
        type = .owner
        if let arr = cert["propertyCert"] as? [String],
            arr.count > 0
        {
            imgs[0][0] = (nil, arr.first)
            if arr.count > 1 {
                imgs[0][1] = (nil, arr.last)
            }
        }
        if let ownerIdP = cert.stringValue("ownerIdP"),
            ownerIdP.count > 0
        {
            imgs[1][0] = (nil, ownerIdP)
        }
        if let ownerIdN = cert.stringValue("ownerIdN"),
            ownerIdN.count > 0
        {
            imgs[1][1] = (nil, ownerIdN)
        }
        
        // 卖房委托 卖方正面 卖方背面
        if let auth = cert.stringValue("auth"),
            auth.count > 0
        {
            type = .agent
            imgs[2][0] = (nil, auth)
        }
        if let agentIdP = cert.stringValue("agentIdP"),
            agentIdP.count > 0
        {
            type = .agent
            imgs[3][0] = (nil, agentIdP)
        }
        if let agentIdN = cert.stringValue("agentIdN"),
            agentIdN.count > 0
        {
            type = .agent
            imgs[3][1] = (nil, agentIdN)
        }
        
        identityHeader.initUI(type)
        tableView.reloadData()
    }
    
    //    MARK: - 懒加载
    /// 选择身份的头
    lazy var identityHeader: AddHouseIdentityHeaderView = {
       let header = AddHouseIdentityHeaderView
                    .initFromNib(AddHouseIdentityHeaderView.self)
        header.delegate = self
        return header
    }()
        
    /// 房主身份证
    lazy var ownerIdCardHeader: AddHouseTitleHeaderView = {
        let header = AddHouseTitleHeaderView.initFromNib(AddHouseTitleHeaderView.self)
        return header
    }()
    
    /// 卖房委托书照片
    lazy var agentHeader: AddHouseTitleHeaderView = {
        let header = AddHouseTitleHeaderView.initFromNib(AddHouseTitleHeaderView.self)
        header.titleLB.text = "卖房委托书照片"
        return header
    }()
    
    /// 卖方身份证照片
    lazy var agentIdCardHeader: AddHouseTitleHeaderView = {
        let header = AddHouseTitleHeaderView.initFromNib(AddHouseTitleHeaderView.self)
        header.titleLB.text = "代理人身份证照片"
        return header
    }()
}

extension AddHousePhotoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return type == .owner ? 2 : 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dzy_dequeueReusableCell(AddHousePhotoCell.self)
        if let type = AddHousePhotoType(rawValue: indexPath.section) {
            cell?.setUI(type, imgs: imgs[indexPath.section])
        }
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 88 : 55
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return identityHeader
        case 1:
            return ownerIdCardHeader
        case 2:
            return agentHeader
        default:
            return agentIdCardHeader
        }
    }
}

extension AddHousePhotoVC: AddHouseIdentityHeaderViewDelegate {
    func identityView(_ identityView: AddHouseIdentityHeaderView, didSelectType type: AddHouseType) {
        self.type = type
        tableView.reloadData()
    }
}

extension AddHousePhotoVC: AddHousePhotoCellDelegate {
    func photoCell(_ photoCell: AddHousePhotoCell, didSelectBtn ifLeft: Bool, type: AddHousePhotoType) {
        var index: (Int, Int) = (0, 0)
        switch type {
        case .ownerCer:
            index = (0, ifLeft ? 0 : 1)
        case .ownerIdCard:
            index = (1, ifLeft ? 0 : 1)
        case .agentCer:
            index = (2, 0)
        case .agentIdCard:
            index = (3, ifLeft ? 0 : 1)
        }
        currentIndex = index
        if let image = imgs[index.0][index.1]?.0 {
            let showView = DzyShowImageView(.image(image))
            showView.show()
        }else {
            let picker = DzyImagePickerVC(.origin(.single))
            picker.delegate = self
            let vc = BaseNavVC(rootViewController: picker)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func photoCell(_ photoCell: AddHousePhotoCell, didSelectCancelBtn ifLeft: Bool, type: AddHousePhotoType) {
        var index: (Int, Int) = (0, 0)
        switch type {
        case .ownerCer:
            index = (0, ifLeft ? 0 : 1)
        case .ownerIdCard:
            index = (1, ifLeft ? 0 : 1)
        case .agentCer:
            index = (2, 0)
        case .agentIdCard:
            index = (3, ifLeft ? 0 : 1)
        }
        imgs[index.0][index.1] = nil
        tableView.reloadData()
    }
}

extension AddHousePhotoVC: DzyImagePickerVCDelegate {
    
    func imagePicker(_ picker: DzyImagePickerVC?, getOriginImage image: UIImage) {
        if let index = currentIndex {
            imgs[index.0][index.1] = (image, nil)
            tableView.reloadSections(IndexSet(integer: index.0), with: .none)
        }
    }
    
    func selectedFinshAndBeginDownload(_ picker: DzyImagePickerVC?) {}
    func imagePicker(_ picker: DzyImagePickerVC?, getImages imgs: [UIImage]) {}
    func imagePicker(_ picker: DzyImagePickerVC?, getCropImage image: UIImage) {}
}
