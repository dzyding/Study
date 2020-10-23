//
//  WatchHouseFooterView.swift
//  YJF
//
//  Created by edz on 2019/5/9.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

protocol WatchHouseFooterViewDelegate: class {
    func didClickAddImageCell(in footerView: WatchHouseFooterView)
    func didClickShowImageCell(in footerView: WatchHouseFooterView, with row: Int)
    func didClickDelBtn(in footerView: WatchHouseFooterView, with row: Int)
    func didClickBuyerMsgBtn(in footerView: WatchHouseFooterView, with btn: UIButton)
    func didClickSellerMsgBtn(in footerView: WatchHouseFooterView, with btn: UIButton)
}

class WatchHouseFooterView: UIView {
    
    let maxNum = PublicConfig.sysConfigIntValue(.look_report_imageNum) ?? 3
    
    private var identity: Identity = .buyer
    
    @IBOutlet weak var remarkTV: UITextView!
    ///输入的 placeHolder
    @IBOutlet weak var placeHolderLB: UILabel!
    /// 损毁金额
    @IBOutlet weak var priceTF: UITextField!
    
    weak var delegate: WatchHouseFooterViewDelegate?
    
    static let collectionCellWidth: CGFloat = (ScreenWidth - 36.0 - 12.0) / 3.0
    
    private var imgs: [(UIImage?, String?)] = []
    
    var height: CGFloat {
        let line = (imgs.count) / 3 + 1
        let cHeight = CGFloat(line) * WatchHouseFooterView.collectionCellWidth
        switch identity {
        case .buyer:
            return 140 + cHeight + 80.0
        case .seller:
            return 140 + cHeight + 134
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var sellerView: UIView!
    
    @IBOutlet weak var sellerReportBtn: UIButton!
    
    @IBOutlet weak var buyerView: UIView!
    
    @IBOutlet weak var buyerReportBtn: UIButton!
    
    func initUI(_ identity: Identity, remark: String?, price: Double?) {
        self.identity = identity
        if identity == .buyer {
            sellerView.isHidden = true
            buyerReportBtn.layer.cornerRadius = 3
            buyerReportBtn.layer.masksToBounds = true
            buyerReportBtn.layer.borderWidth = 1
            buyerReportBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
            placeHolderLB.text = "请输入您的描述"
        }else {
            buyerView.isHidden = true
            sellerReportBtn.layer.cornerRadius = 3
            sellerReportBtn.layer.masksToBounds = true
            sellerReportBtn.layer.borderWidth = 1
            sellerReportBtn.layer.borderColor = dzy_HexColor(0xFD7E25).cgColor
            placeHolderLB.text = "请输入损毁描述"
        }
        remarkTV.text = remark
        remarkTV.delegate = self
        placeHolderLB.isHidden = (remark?.count ?? 0 > 0)
        priceTF.text = price?.decimalStr
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dzy_registerCellFromNib(AddImageCell.self)
        collectionViewHeightLC.constant = WatchHouseFooterView.collectionCellWidth
    }
    
    func updateUI(_ imgs: [(UIImage?, String?)]) {
        self.imgs = imgs
        collectionView.reloadData()
    }
    
    func getRemark() -> String {
        return remarkTV.text
    }
    
    func getPrice() -> Double {
        if let price = Double(priceTF.text ?? "0") {
            return price
        }else {
            return 0
        }
    }
    
    @IBAction private func buyerMsgAction(_ sender: UIButton) {
        delegate?.didClickBuyerMsgBtn(in: self, with: sender)
    }
    
    @IBAction private func sellerMsgAction(_ sender: UIButton) {
        delegate?.didClickSellerMsgBtn(in: self, with: sender)
    }
    
}

extension WatchHouseFooterView:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(maxNum, imgs.count + 1)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dzy_dequeueCell(AddImageCell.self, indexPath)
        if indexPath.row < imgs.count {
            cell?.updateUI(imgs[indexPath.row], indexPath: indexPath)
        }else {
            cell?.updateUI(nil, indexPath: indexPath)
        }
        cell?.delegate = self
        return cell!
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let x = WatchHouseFooterView.collectionCellWidth
        return CGSize(width: x, height: x)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 6.0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 6.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imgs.count < maxNum && indexPath.row == imgs.count {
            delegate?.didClickAddImageCell(in: self)
        }else {
            delegate?.didClickShowImageCell(in: self, with: indexPath.row)
        }
    }
}

extension WatchHouseFooterView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        placeHolderLB.isHidden = count > 0
    }
}

extension WatchHouseFooterView: AddImageCellDelegate {
    func imageCell(_ imageCell: AddImageCell, didClickDelBtn btn: UIButton) {
        if let index = imageCell.indexPath {
            delegate?.didClickDelBtn(in: self, with: index.row)
        }
    }
}
