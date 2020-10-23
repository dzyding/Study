//
//  AddHouseFurnitureVC.swift
//  YJF
//
//  Created by edz on 2019/5/11.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class AddHouseFurnitureVC: BaseVC {
    /// cell 中显示数据的左右边距
    private var itemPadding: CGFloat = 20.0
    /// collectionView 左右的
    private var lrPadding: CGFloat = 28.0
    /// collectionView 横向
    private var xPadding: CGFloat = 32.0
    /// collectionView 纵向
    private var yPadding: CGFloat = 15.0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var inputTF: UITextField!
    
    var datas:[(String, CGFloat)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    private func setUI() {
        checkEmptyView()
        addBtn.layer.masksToBounds = true
        addBtn.layer.cornerRadius = 3
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = MainColor.cgColor
        inputTF.addTarget(self, action: #selector(editingEnd(_:)), for: .editingDidEnd)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dzy_registerCellFromNib(AddFurnitureCell.self)
    }
    
    //    MARK: - 撤销的重新提交时，初始化视图
    func initUI(_ equipList: [[String : Any]]) {
        let names = equipList.compactMap({$0.stringValue("name")})
        names.forEach { (text) in
            let width = getTheWidth(text)
            datas.append((text, width))
        }
        checkEmptyView()
        collectionView.reloadData()
    }
    
    @objc private func editingEnd(_ tf: UITextField) {
        if let text = tf.text,
            text.count > 8
        {
            let index = text.index(text.startIndex, offsetBy: 7)
            tf.text = String(text[...index])
        }
    }
    
    private func checkEmptyView() {
        if datas.count == 0 {
            emptyView.isHidden = false
            collectionView.isHidden = true
        }else {
            collectionView.isHidden = false
            emptyView.isHidden = true
        }
    }
    
    func removeAction(_ row: Int) {
        datas.remove(at: row)
        collectionView.reloadData()
        checkEmptyView()
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        let text = inputTF.text ?? ""
        guard text.count > 0 else {
            showMessage("请输入家具电器名称")
            return
        }
        let width = getTheWidth(text)
        datas.append((text, width))
        inputTF.text = nil
        collectionView.reloadData()
        checkEmptyView()
    }
    
    //    MARK: - 计算宽度
    private func getTheWidth(_ text: String) -> CGFloat {
        let minW = (ScreenWidth - 2 * (lrPadding + xPadding)) / 3.0
        var width = dzy_strSize(str: text, font: dzy_Font(13)).width
        width += (itemPadding * 2.0)
        width = max(width, minW)
        return width
    }
}

extension AddHouseFurnitureVC:
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
    ) -> UICollectionViewCell {
        let cell = collectionView.dzy_dequeueCell(AddFurnitureCell.self, indexPath)
        cell?.titleLB.text = datas[indexPath.row].0
        cell?.handelr = { [weak self] in
            self?.removeAction(indexPath.row)
        }
        return cell!
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: datas[indexPath.row].1, height: 35.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return xPadding
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return yPadding
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: lrPadding, bottom: 0, right: lrPadding)
    }
}
