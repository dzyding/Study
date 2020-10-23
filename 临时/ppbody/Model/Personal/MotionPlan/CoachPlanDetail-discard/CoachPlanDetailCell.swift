//
//  CoachPlanDetailCell.swift
//  PPBody
//
//  Created by Mike on 2018/7/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol CoachPlanDetailCellDelegate:NSObjectProtocol {
    func deleteAction(_ cell: CoachPlanDetailCell)
    func detailAction(_ cell: CoachPlanDetailCell)

}

class CoachPlanDetailCell: UITableViewCell {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var numOfGroupLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var groupLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    
    weak var delegate:CoachPlanDetailCellDelegate?
    var motion:[String:Any]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(motionDetailAction(_:))))
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        
        let alert = UIAlertController.init(title: "请确认是否删除该动作？", message: "", preferredStyle: .alert)
        let actionN = UIAlertAction.init(title: "是", style: .default) { (_) in
            self.delegate?.deleteAction(self)
        }
        let actionY = UIAlertAction.init(title: "否", style: .cancel) { (_) in
            
        }
        alert.addAction(actionN)
        alert.addAction(actionY)
        ToolClass.controller2(view: self)?.present(alert, animated: true, completion: nil)
    }
    

    
    func setData(data: [String: Any], delete: Bool) {
        print(data)
        motion = data["motion"] as? [String: Any]
        let target = data["target"] as! [String: Any]
        
        titleLbl.text = motion!["name"] as? String
        iconImg.setHeadImageUrl(motion!["cover"] as! String)
        
        let time = target["time"] as? Int
        
        if time == nil {
            self.weightLbl.isHidden = false
            self.numOfGroupLbl.isHidden = false
            groupLbl.text = "\(target["groupNum"] ?? 0)组"
            weightLbl.text = "\(target["weight"] ?? 0)kg"
            numOfGroupLbl.text = "\(target["freNum"] ?? 0)个/组"
        }else{
            groupLbl.text = "\(time!)分钟"
            self.weightLbl.isHidden = true
            self.numOfGroupLbl.isHidden = true
        }
    
        
        if delete{
            self.deleteBtn.isHidden = false
        }else{
            self.deleteBtn.isHidden = true
        }
    }
    
    @IBAction func motionDetailAction(_ sender: UIButton) {
        self.delegate?.detailAction(self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
