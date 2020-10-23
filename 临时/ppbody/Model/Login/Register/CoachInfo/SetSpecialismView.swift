//
//  SetSpecialismView.swift
//  PPBody
//
//  Created by Mike on 2018/6/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ExpertiseCellSpaceFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        scrollDirection = UICollectionView.ScrollDirection.vertical
        minimumLineSpacing = 8
        minimumInteritemSpacing = 8
        sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attrsArry = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        for i in 0..<attrsArry.count {
            if i != attrsArry.count-1 {
                let curAttr = attrsArry[i] //当前attr
                let nextAttr = attrsArry[i+1]  //下一个attr
                //如果下一个在同一行则调整，不在同一行则跳过
                if curAttr.frame.minY == nextAttr.frame.minY {
                    if nextAttr.frame.minX - curAttr.frame.maxX > minimumInteritemSpacing{
                        var frame = nextAttr.frame
                        let x = curAttr.frame.maxX + minimumInteritemSpacing
                        frame = CGRect(x: x, y: frame.minY, width: frame.width, height: frame.height)
                        nextAttr.frame = frame
                    }
                }
            }
        }
        return attrsArry

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
}


class SetSpecialismView: UIView {
    
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
        collectionview.backgroundColor = CardColor
    
        
        collectionview.performBatchUpdates({
            collectionview.reloadData()
        }) { (finish) in
            self.collectionViewHeight.constant = self.collectionview.contentSize.height + 10
            self.collectionview.na_height = self.collectionViewHeight.constant
        }
    }
    
    class func instanceFromNib() -> SetSpecialismView {
        return UINib(nibName: "SetCoachView", bundle: nil).instantiate(withOwner: nil, options: nil)[1] as! SetSpecialismView
    }
    
}



extension SetSpecialismView:UICollectionViewDelegate, UICollectionViewDataSource
{
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
            let index = selectArr.firstIndex(of: selectCell.lblContent.text!)
            selectArr.remove(at: index!)
            selectCell.backgroundColor = UIColor.ColorHex("#4a4a4a")
            selectCell.lblContent.textColor = UIColor.white
            selectCell.layer.borderColor = selectCell.backgroundColor?.cgColor
        }
    }
}


















