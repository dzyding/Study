//
//  CollectionFilterBaseView.swift
//  YJF
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import ZKProgressHUD

protocol CollectionFilterViewDelegate: class {
    func cfView(
        _ cfView: CollectionFilterView,
        didClickSureBtnWithValue value: (Int, Int)?,
        showText str: String?,
        type: String
    )
    func cfView(_ cfView: CollectionFilterView, didClickSureBtnWithStrings strings: [String]?)
    
    func cfView(_ cfView: CollectionFilterView, didClickClearBtn btn: UIButton)
}

class CollectionFilterView: UIView {
    
    weak var delegate: CollectionFilterViewDelegate?
    
    var type: FilterType = .area
    
    /// 描述词
    private var desString: String {
        switch type {
        case .area:
            return "㎡"
        case .price:
            return "万"
        default:
            return ""
        }
    }
    /// collectionView 到两按钮的高度
    private var bottomValue: CGFloat {
        switch type {
        case .area, .price:
            return 50
        default:
            return 0
        }
    }
    //swiftlint:disable:next large_tuple
    private var datas: [(String, Bool, (Int, Int)?)] = []

    @IBOutlet weak var collectionBottomLC: NSLayoutConstraint!
    /// 左边的描述词
    @IBOutlet weak var leftDes: UILabel!
    /// 右边的描述词
    @IBOutlet weak var rightDes: UILabel!
    @IBOutlet weak var leftTF: UITextField!
    @IBOutlet weak var rightTF: UITextField!
    /// 内容视图
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        leftTF.delegate = self
        rightTF.delegate = self
        collectionView.dzy_registerCellFromNib(CollectionFilterCell.self)
    }
    
    func updateUI(_ type: FilterType) {
        self.type = type
        leftDes.text = desString
        rightDes.text = desString
        collectionBottomLC.constant = bottomValue
        
        switch type {
        case .area:
            datas = [
                ("50㎡以下", false, (0, 50)), ("50-70㎡", false, (50, 70)), ("70-90㎡", false, (70, 90)),
                ("90-110㎡", false, (90, 110)), ("110-130㎡", false, (110, 130)), ("130-150㎡", false, (130, 150)),
                ("150-200㎡", false, (150, 200)), ("200㎡以上", false, (200, 9999))
            ]
            frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 265)
        case .price:
            datas = [
                ("80万以下", false, (0, 80)), ("80~100万", false, (80, 100)), ("100~150万", false, (100, 150)),
                ("150~200万", false, (150, 200)), ("200~300万", false, (200, 300)), ("300万以上", false, (300, 9999))
            ]
            frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 220)
        case .houseType:
            datas = [
                ("1居", false, nil), ("2居", false, nil), ("3居", false, nil),
                ("4居", false, nil), ("5居", false, nil), ("5居以上", false, nil)
            ]
            frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 170)
        default:
            break
        }
        collectionView.reloadData()
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        delegate?.cfView(self, didClickClearBtn: sender)
    }
    
    func reset() {
        if type != .houseType {
            leftTF.text = nil
            rightTF.text = nil
        }
        (0..<datas.count).forEach { (index) in
            datas[index].1 = false
        }
        collectionView.reloadData()
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        if type == .houseType {
            let strs = datas.filter({$0.1}).map({$0.0})
            delegate?.cfView(
                self,
                didClickSureBtnWithStrings: strs.count == 0 ? nil : strs
            )
        }else {
            let sValue = datas.filter({$0.1}).first
            let leftValue = leftTF.text
            let rightValue = rightTF.text
            if let sValue = sValue { // 有选择
                delegate?.cfView(self, didClickSureBtnWithValue: sValue.2, showText: sValue.0, type: type.rawValue)
            }else if (leftValue?.count ?? 0) > 0 ||
                (rightValue?.count ?? 0) > 0 { // 有输入
                let min = Int(leftValue ?? "0") ?? 0
                let max = Int(rightValue ?? "9999") ?? 9999
                var text = ""
                if min == 0 {
                    text = "\(max)" + desString + "以下"
                }else if max == 9999 {
                    text = "\(min)" + desString + "以上"
                }else {
                    text = "\(min)-\(max)" + desString
                }
                guard min <= max else {
                    ZKProgressHUD
                        .showMessage("输入必须遵守从小到大，不然将无法查出数据")
                    return
                }
                delegate?.cfView(self, didClickSureBtnWithValue: (min, max), showText: text, type: type.rawValue)
            }else { // 什么都没选
                delegate?.cfView(self, didClickSureBtnWithValue: nil, showText: nil, type: type.rawValue)
            }
        }
    }
}

extension CollectionFilterView:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell
    {
        let cell = collectionView.dzy_dequeueCell(CollectionFilterCell.self, indexPath)
        cell?.updateUI(datas[indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        leftTF.text = nil
        rightTF.text = nil
        endEditing(true)
        if type == .houseType { // 户型可以多选
            datas[indexPath.row].1 = !datas[indexPath.row].1
        }else {
            (0..<datas.count).forEach { (index) in
                datas[index].1 = false
            }
            datas[indexPath.row].1 = true
        }
        collectionView.reloadData()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize
    {
        let width = ScreenWidth / 3.0
        return CGSize(width: width, height: 45)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
}

extension CollectionFilterView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (0..<datas.count).forEach { (index) in
            datas[index].1 = false
        }
        collectionView.reloadData()
    }
    
}
