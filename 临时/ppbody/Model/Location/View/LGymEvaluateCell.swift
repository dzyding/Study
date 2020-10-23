//
//  LGymEvaluateCell.swift
//  PPBody
//
//  Created by edz on 2019/10/24.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class LGymEvaluateCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    /// 93
    @IBOutlet weak var clViewHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var headIV: UIImageView!
    
    @IBOutlet weak var nickNameLB: UILabel!
    
    @IBOutlet weak var timeLB: UILabel!
    
    @IBOutlet weak var rankSV: UIStackView!
    
    @IBOutlet weak var infoLB: UILabel!
    
    @IBOutlet weak var replyLB: UILabel!
    
    private var imgs: [String] = []
    
    private let width = (ScreenWidth - 68.0 - 16.0 - 18.0) / 4.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    private func initUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dzy_registerCellFromNib(ImagePublicCell.self)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 6.0
        layout.minimumLineSpacing = 6.0
        collectionView.collectionViewLayout = layout
    }
    
    func updateUI(_ comment: [String : Any]) {
        let rank = comment.intValue("score") ?? 0
        let time = comment.stringValue("createTime") ?? ""
        timeLB.text = ToolClass.compareCurrentTime(date: time)
        updateRank(rank)
        nickNameLB.text = comment.stringValue("nickname")
        headIV.dzy_setCircleImg(comment.stringValue("head") ?? "", ScreenScale * 42.0)
        infoLB.text = comment.stringValue("content")
        imgs = (comment["imgs"] as? [String]) ?? []
        let count = imgs.count
        let row = count % 4 == 0 ? (count / 4) : (count / 4 + 1)
        var constant = width * CGFloat(row)
        if row > 1 {
            constant += CGFloat(row - 1) * 6.0
        }
        updateReply(comment.stringValue("reply"))
        clViewHeightLC.constant = constant
        collectionView.reloadData()
    }
    
    private func updateReply(_ reply: String?) {
        if let reply = reply,
            reply.count > 0
        {
            let attStr = NSMutableAttributedString(string: reply, attributes: [
                NSAttributedString.Key.font : dzy_FontBlod(12),
                NSAttributedString.Key.foregroundColor : UIColor.white
            ])
            attStr.insert(NSAttributedString(string: "商家回复：", attributes: [
                NSAttributedString.Key.font : dzy_FontBlod(12),
                NSAttributedString.Key.foregroundColor : YellowMainColor
            ]), at: 0)
            replyLB.attributedText = attStr
        }else {
            replyLB.text = nil
        }
    }
    
    private func updateRank(_ rank: Int) {
        rankSV.arrangedSubviews.enumerated().forEach { (index, view) in
            if let imgIV = view as? UIImageView {
                let imageName = index < rank ?
                    "lgym_evaluate_light" : "lgym_evaluate"
                imgIV.image = UIImage(named: imageName)
            }
        }
    }
}

extension LGymEvaluateCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dzy_dequeueCell(ImagePublicCell.self, indexPath)
        cell?.coverIV.setCoverImageUrl(imgs[indexPath.row])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let showView = DzyShowImageView(.more(imgs, indexPath.row))
        showView.show()
    }
}
