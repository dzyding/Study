//
//  AddHousePhotoCell.swift
//  YJF
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

@objc enum AddHousePhotoType: Int {
    case ownerCer     //房产证
    case ownerIdCard  //房主身份证
    case agentCer     //委托书
    case agentIdCard  //委托人身份证
}

@objc protocol AddHousePhotoCellDelegate {
    func photoCell(_ photoCell: AddHousePhotoCell, didSelectBtn ifLeft: Bool, type: AddHousePhotoType)
    func photoCell(_ photoCell: AddHousePhotoCell, didSelectCancelBtn ifLeft: Bool, type: AddHousePhotoType)
}

class AddHousePhotoCell: UITableViewCell {
    
    weak var delegate: AddHousePhotoCellDelegate?

    @IBOutlet weak var stackView: UIStackView!
    
    private var type: AddHousePhotoType = .agentCer
    
    private var imgs: [(UIImage?, String?)?] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc private func btnAction(_ btn: UIButton) {
        delegate?.photoCell(self, didSelectBtn: btn.tag == 1, type: type)
    }
    
    @objc private func cancelAction(_ btn: UIButton) {
        delegate?.photoCell(self, didSelectCancelBtn: btn.tag == 1, type: type)
    }
    
    func setUI(_ type: AddHousePhotoType, imgs: [(UIImage?, String?)?]) {
        while stackView.arrangedSubviews.count > 0 {
            stackView.arrangedSubviews.first?.removeFromSuperview()
        }
        self.type = type
        self.imgs = imgs
        var photoNames: [String] = []
        switch type {
        case .agentCer:
            photoNames = ["add_house_agent_cer", ""]
        case .agentIdCard, .ownerIdCard:
            photoNames = ["add_house_idcard_up", "add_house_idcard_back"]
        case .ownerCer:
            photoNames = ["add_house_owner_cer", "add_house_owner_cer"]
        }
    
        photoNames.enumerated().forEach { (index, name) in
            if name.count > 0 {
                let view = showView(index, imgs: imgs, name: name)
                stackView.addArrangedSubview(view)
            }else {
                let view = UIView()
                view.backgroundColor = .white
                stackView.addArrangedSubview(view)
            }
        }
    }
    
    private func showView(_ index: Int, imgs: [(UIImage?, String?)?], name: String) -> UIView {
        let view = UIView()
        let btn = UIButton(type: .custom)
        btn.imageView?.contentMode = .scaleAspectFill
        if imgs[index] != nil {
            if let image = imgs[index]?.0 {
                btn.setImage(image, for: .normal)
            }else if let url = imgs[index]?.1 {
                btn.dzy_setImg(url)
            }
            let cancelBtn = UIButton(type: .custom)
            cancelBtn.setImage(UIImage(named: "watch_del_img"), for: .normal)
            cancelBtn.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
            cancelBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 0)
            cancelBtn.tag = index + 1
            view.addSubview(cancelBtn)
            
            cancelBtn.snp.makeConstraints { (make) in
                make.width.height.equalTo(45)
                make.top.right.equalTo(0)
            }
        }else {
            btn.setImage(UIImage(named: name), for: .normal)
        }
        btn.tag = index + 1
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        view.insertSubview(btn, at: 0)
        
        btn.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(UIEdgeInsets.zero)
        }
        return view
    }
}
