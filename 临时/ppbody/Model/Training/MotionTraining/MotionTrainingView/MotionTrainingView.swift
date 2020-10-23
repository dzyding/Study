//
//  MotionTrainingView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/5/23.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

typealias SelectBlock = (String)->Void

class MotionTrainingView: UIView
{
    var collectionview: UICollectionView!
    
    var numCount = 100
    var minNum = 1
    var unit:Float = 1
    
    var dataArr = [String]()
    
    var flowlayout:MotionTrainingFlowLayout!
    
    var selectBlock:SelectBlock?//中间值的回调
    
    
    weak var delegate: MotionSelectDelegate?
    
    var selectInitIndex = 10{
        didSet{
            if self.dataArr.count > selectInitIndex
            {
                collectionview.scrollToItem(at: IndexPath(row: selectInitIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    var initSelectCell = false
    
    var initScrollCell = false
    
    var selectTex = ""
    
    override func awakeFromNib() {
        
        let padding = FIT_SCREEN_WIDTH(4)
        
        flowlayout = MotionTrainingFlowLayout()
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 20
        flowlayout.minimumInteritemSpacing = 20
        flowlayout.sectionInset = UIEdgeInsets(top: padding, left: 0, bottom: padding, right: 0)
        let itemW = self.na_height - padding * 2
        flowlayout.itemSize = CGSize(width: itemW + 16, height: itemW)
        
        self.collectionview = UICollectionView(frame: self.bounds, collectionViewLayout: flowlayout)
        self.collectionview.backgroundColor = self.backgroundColor
        self.collectionview.collectionViewLayout = flowlayout
        self.collectionview.showsHorizontalScrollIndicator = false
        self.collectionview.delegate = self
        self.collectionview.dataSource = self
        
        self.collectionview.register(UINib(nibName: "MotionTrainingCell", bundle: nil), forCellWithReuseIdentifier: "MotionTrainingCell")
        
        self.addSubview(self.collectionview)
        self.collectionview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
    }
    
    override func layoutSubviews() {
        
        print(self.dataArr.count,"layoutsubviews")
        
        self.collectionview.setNeedsLayout()
        self.collectionview.layoutIfNeeded()
        
        let padding = FIT_SCREEN_WIDTH(4)
        let itemW = self.na_height - padding * 2

        flowlayout.sectionInset = UIEdgeInsets(top: padding, left: self.na_width/2 - itemW/2, bottom: padding, right: self.na_width/2 - itemW/2)
        let indexPath = IndexPath(row: selectInitIndex, section: 0)
        
        collectionview.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        print("ending")
    }
    
    func setTotalNum(_ maxNum:Int, unit:Float, zero: Bool = false)
    {
        initSelectCell = false
        selectInitIndex = 10
        
        if self.dataArr.count > 0
        {
            let indexPath = IndexPath(row: selectInitIndex, section: 0)
            
            collectionview.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            return
        }
 
        if unit == 1
        {
            for i in minNum...maxNum
            {
                self.dataArr.append("\(i)")
            }
        }else if unit == 0.5 {
            for i in minNum..<30
            {
                self.dataArr.append("\(i)")
              
                self.dataArr.append((Float(i)+0.5).removeDecimalPoint)

            }
            
            for i in 30...maxNum
            {
                self.dataArr.append("\(i)")
            }
            
            if zero
            {
                self.dataArr.insert("自重", at: 0)
            }
        }
        
        self.collectionview.reloadData()

        self.collectionview.layoutIfNeeded()


    }
    
    func setSelectStatusForCell(_ cell: MotionTrainingCell, isSelect: Bool)
    {
        if isSelect
        {
            cell.numLB.textColor = YellowMainColor
            cell.numLB.font = UIFont.boldSystemFont(ofSize: 20)
        }else{
            cell.numLB.textColor = UIColor.white
            cell.numLB.font = ToolClass.CustomFont(20)
        }
    }

    //滑动到哪里
    func scrollToItem(_ txt: String)
    {
        let index = dataArr.firstIndex(of: txt)
        let indexPath = IndexPath(row: index!, section: 0)
        collectionview.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func resetStyle()
    {
        let cells = self.collectionview.visibleCells
        for cell in cells
        {
            let motionCell = cell as! MotionTrainingCell
            setSelectStatusForCell(motionCell, isSelect: false)
        }
    }
    
}

extension MotionTrainingView: UICollectionViewDelegate, UICollectionViewDataSource
{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        let cells = self.collectionview.visibleCells
        for cell in cells
        {
            let motionCell = cell as! MotionTrainingCell
            let pointInView = self.collectionview.convert(motionCell.center, to: self)
            print(pointInView)

            if abs(pointInView.x - self.na_width/2) < 1
            {
                print("select true")
                setSelectStatusForCell(motionCell, isSelect: true)
                self.selectTex = motionCell.numLB.text!
                if self.selectBlock != nil {
                    self.selectBlock!(self.selectTex)
                }
            }else{
                print("select false")
                
                let indexPath = self.collectionview.indexPath(for: cell)
                
                
                if indexPath?.row == self.selectInitIndex && !initScrollCell
                {
                    initScrollCell = true
                    continue
                }

                setSelectStatusForCell(motionCell, isSelect: false)
            }
    
        }
        
        //滑动自重就取消
        let vc = ToolClass.controller2(view: self)
        if let parent = vc as? MotionTrainingVC
        {
            parent.zizhongBtn.isSelected = false
        }
    }
    
    // MARK:- CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MotionTrainingCell", for: indexPath) as! MotionTrainingCell

        cell.numLB.text = self.dataArr[indexPath.row]
        
       
        if indexPath.row == self.selectInitIndex && !initSelectCell
        {
            print("select cell")
            cell.numLB.textColor = YellowMainColor
            cell.numLB.font = UIFont.boldSystemFont(ofSize: 20)
            self.selectTex = cell.numLB.text!
            if self.selectBlock != nil {
                self.selectBlock!(self.selectTex)
            }
            initSelectCell = true
        }
        else {
            cell.numLB.textColor = UIColor.white
            cell.numLB.font = ToolClass.CustomFont(20)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}
