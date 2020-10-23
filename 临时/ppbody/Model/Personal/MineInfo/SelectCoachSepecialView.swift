//
//  SelectCoachSepecialView.swift
//  PPBody
//
//  Created by Mike on 2018/7/4.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class SelectCoachSepecialView: UIView {

    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewContent: UIView!
    
    var collectionview: UICollectionView!
    
    var selectArr = [String]()
    
    var dataStr = "健美操 有氧操 踏板操 搏击操 杠铃操 动感单车 普拉提 瑜伽 体适能训练 抗阻力训练 形体训练 功能性器械训练 运动康复 减脂课程 孕产康复 增肌训练 体态调整 减脂训练、塑形训练 拳击训练 运动营养 HIIT全身燃脂 肌肉拉伸按摩"
    lazy var arrData: [String] = {
        let arr = self.dataStr.components(separatedBy: " ")
        return arr
    }()
    
    
    func getDicData() -> String? {
        if selectArr.count == 0 {
            ToolClass.showToast("请选择教练专长", .Failure)
            return nil
        }
        return selectArr.joined(separator: "|")
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        let flowLayout = ExpertiseCellSpaceFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width:100, height:25)
        
        collectionview = UICollectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 32, height: self.collectionViewHeight.constant), collectionViewLayout: flowLayout)
        
        self.viewContent.addSubview(collectionview)
        
        
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.isScrollEnabled = false
        collectionview.register(SetCommonCell.self, forCellWithReuseIdentifier: "SetCommonCell")
        collectionview.backgroundColor = UIColor.clear
        
        
        collectionview.performBatchUpdates({
            collectionview.reloadData()
        }) { (finish) in
            self.collectionViewHeight.constant = self.collectionview.contentSize.height + 20
            self.collectionview.na_height = self.collectionViewHeight.constant
        }
    }
    
    
    class func instanceFromNib() -> SelectCoachSepecialView {
        return UINib(nibName: "SelectCoachSepecialView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SelectCoachSepecialView
    }

}

extension SelectCoachSepecialView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetCommonCell", for: indexPath) as! SetCommonCell
        cell.lblContent.text = self.arrData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectCell = collectionView.cellForItem(at: indexPath) as! SetCommonCell
        if !selectArr.contains(selectCell.lblContent.text!) {
            selectArr.append(selectCell.lblContent.text!)
            selectCell.backgroundColor = UIColor.ColorHex("#5a5632")
            selectCell.lblContent.textColor = YellowMainColor
            selectCell.layer.borderColor = YellowMainColor.cgColor
        }
        else {
            guard let text = selectCell.lblContent.text,
                let index = selectArr.firstIndex(of: text)
            else {
                return
            }
            selectArr.remove(at: index)
            selectCell.backgroundColor = UIColor.ColorHex("#4a4a4a")
            selectCell.lblContent.textColor = UIColor.white
            selectCell.layer.borderColor = selectCell.backgroundColor?.cgColor
        }
    }
    
}









