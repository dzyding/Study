//
//  MotionGroupView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/20.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

protocol MotionSelectDelegate: class {
    func selectMotion(_ code: String)
}

class MotionGroupView: UIView {
    
    var collectionview: UICollectionView!
    
    var initScrollItem = 0
    
    let motionArr = [["name":"胸部","code":"MG10000","eng":"Chest","bg":"motion_chest"],
                     ["name":"背部","code":"MG10001","eng":"Back","bg":"motion_back"],
                     ["name":"肩部","code":"MG10002","eng":"Shoulder","bg":"motion_shoulder"],
                     ["name":"腹部","code":"MG10003","eng":"Abs","bg":"motion_abdomen"],
                     ["name":"手臂","code":"MG10004","eng":"Arm","bg":"motion_arm"],
                     ["name":"臀腿","code":"MG10005","eng":"Leg","bg":"motion_buttock"],
                     ["name":"有氧","code":"MG10006","eng":"Cardio","bg":"motion_aerobic"]]
    var indexArr = [Int]() // 存储图片下标，解决制造100组图片数据占用过大内存问题
    
    weak var delegate: MotionSelectDelegate?
    
    override func awakeFromNib() {
        
        let padding = FIT_SCREEN_WIDTH(16)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        let itemW = self.na_height - padding * 2
        layout.itemSize = CGSize(width: itemW, height: itemW)
        
        self.collectionview = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        self.collectionview.backgroundColor = BackgroundColor
        self.collectionview.showsHorizontalScrollIndicator = false
        self.collectionview.delegate = self
        self.collectionview.dataSource = self
        
        
        self.collectionview.register(UINib(nibName: "MotionGroupCell", bundle: nil), forCellWithReuseIdentifier: "MotionGroupCell")
        
        self.addSubview(self.collectionview)
        
        self.collectionview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        ininRecyleData()
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        collectionview.setNeedsLayout()
//        collectionview.layoutIfNeeded()
//        
//        // 定位到 第50组(中间那组)
////        collectionview.scrollToItem(at: NSIndexPath.init(item: groupCount / 2 * motionArr.count + initScrollItem, section: 0) as IndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
//    }
    
    func ininRecyleData()
    {
        //        for _ in 0 ..< groupCount {
        //            for j in 0 ..< motionArr.count {
        //                indexArr.append(j)
        //            }
        //        }
        for j in 0 ..< motionArr.count {
            indexArr.append(j)
        }
    }
    
    //根据code匹配返回相应的数据
    func setCodeAndScrollToItem(_ code: String) -> String
    {
        for i in 0..<motionArr.count {
            let item = motionArr[i]
            let origin = item["code"]
            if code.range(of: origin!) != nil
            {
                initScrollItem = i
                collectionview.scrollToItem(at: IndexPath(item:  i, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                return origin!
            }
        }
        return ""
    }
}

extension MotionGroupView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // MARK:- CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return indexArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MotionGroupCell", for: indexPath) as! MotionGroupCell
        
        let index = indexArr[indexPath.row]
        cell.index = index
        cell.setData(motionArr[index])
        
        if indexPath.row == self.initScrollItem
        {
            cell.layer.borderColor = YellowMainColor.cgColor
            cell.layer.borderWidth = 1
        }else{
            cell.layer.borderColor = nil
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let index = indexPath.row % motionArr.count
        let dic = motionArr[index]
        self.delegate?.selectMotion(dic["code"]!)
        
        
        self.initScrollItem = indexPath.row
        
        self.collectionview.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = FIT_SCREEN_WIDTH(16)
        let itemW = self.na_height - padding * 2
        return CGSize(width: itemW, height: itemW)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
//        let pointInView = self.convert(collectionview.center, to: collectionview)
//        let indexPathNow =  collectionview.indexPathForItem(at: pointInView)
//        let index = (indexPathNow?.row ?? 0) % motionArr.count
//        let curIndexStr = String(format: "滚动至第%d张", index + 1)
//        print(curIndexStr)
//
//        // 动画停止, 重新定位到 第50组(中间那组) 模型
////        collectionview.scrollToItem(at: NSIndexPath.init(item: groupCount / 2 * motionArr.count + index, section: 0) as IndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
//
//        let dic = motionArr[index]
//
//        self.delegate?.selectMotion(dic["code"]!)
    }
}
