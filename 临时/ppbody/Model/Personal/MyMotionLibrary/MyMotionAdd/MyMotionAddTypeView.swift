//
//  MyMotionAddTypeView.swift
//  PPBody
//
//  Created by edz on 2020/4/18.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class MyMotionAddTypeView: UIView {

    @IBOutlet weak var positionCL: UICollectionView!
    
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var clHeightLC: NSLayoutConstraint!
    
    var datas: [[String : Any]] = [
        [
            "name" : "胸大肌",
            SelectedKey : true
        ],
        [
            "name" : "胸小肌",
            SelectedKey : false
        ],
        [
            "name" : "肋间肌",
            SelectedKey : false
        ],
        [
            "name" : "肱二头肌",
            SelectedKey : false
        ]
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        positionCL.delegate = self
        positionCL.dataSource = self
        positionCL
            .dzy_registerCellFromNib(MyMotionAddTypeCell.self)
    }
    
    static func initFromNib() -> MyMotionAddTypeView {
        return Bundle.main.loadNibNamed("MyMotionAddView", owner: nil, options: nil)?[3] as! MyMotionAddTypeView
    }

    func updateUI(_ num: Int) {
        let row = num % 3 == 0 ? num / 3 : (num / 3 + 1)
        clHeightLC.constant = (36 + 10) * CGFloat(row)
    }
    
    @IBAction func typeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    func getInfo() -> [String : Any]? {
        let position = datas
            .filter({$0.boolValue(SelectedKey) == true})
            .compactMap({$0.stringValue("name")})
            .joined(separator: "|")
        if position.isEmpty {
            ToolClass.showToast("请选择训练部位", .Failure)
            return nil
        }
        return [
            "position" : position,
            "type" : typeBtn.isSelected ? "20" : "10"
        ]
    }
}

extension MyMotionAddTypeView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 32 - 28) / 3.0
        return CGSize(width: width, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(MyMotionAddTypeCell.self, indexPath)
        cell?.titleLB.text = datas[indexPath.row].stringValue("name")
        if datas[indexPath.row].boolValue(SelectedKey) == true {
            cell?.borderUI()
        }else {
            cell?.emptyUI()
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let old = datas[indexPath.row]
            .boolValue(SelectedKey) ?? false
        datas[indexPath.row][SelectedKey] = !old
        collectionView.reloadData()
    }
}
