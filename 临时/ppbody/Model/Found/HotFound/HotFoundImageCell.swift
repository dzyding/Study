//
//  HotFoundImageCell.swift
//  PPBody
//
//  Created by edz on 2020/7/10.
//  Copyright © 2020 Nathan_he. All rights reserved.
//

import UIKit

class HotFoundImageCell: UITableViewCell {
    
// ---- 通用 UI
    @IBOutlet weak var scrollView: UIScrollView!
    /// 姓名
    @IBOutlet weak var nameLB: UILabel!
    /// 标签
    @IBOutlet weak var briefLB: UILabel!
    /// 头像
    @IBOutlet weak var logoIV: UIImageView!
    /// 内容
    @IBOutlet weak var contentLB: UILabel!
    /// 0人浏览
    @IBOutlet weak var lookNumLB: UILabel!
    /// 共0条评论
    @IBOutlet weak var commentLB: UILabel!
    /// 上面的评论
    @IBOutlet weak var topCommentLB: UILabel!
    /// 下面的评论
    @IBOutlet weak var bottomCommentLB: UILabel!
    /// 80 50 0
    @IBOutlet weak var commentHLC: NSLayoutConstraint!
// ---- 通用 UI
    
    @IBOutlet weak var pageLB: UILabel!
    
    private var imgCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func initUI() {
        
    }
    
    func updateUI(_ dic: [String : Any]) {
        let imgs = dic["imgs"] as? [String] ?? []
        updateScrollView(imgs)
        baseUpdateUI(dic)
    }
    
    private func updateScrollView(_ imgs: [String]) {
        let count = imgs.count
        let height: CGFloat = 400
        imgCount = count
        scrollView.contentOffset.x = 0
        scrollView.contentSize = CGSize(
            width: CGFloat(count) * ScreenWidth,
            height: height)
        pageLB.text = "1/\(count)"
        pageLB.isHidden = count <= 1
        (0..<count).forEach { (index) in
            if index < scrollView.subviews.count {
                let imgView = scrollView.subviews[index] as? UIImageView
                imgView?.setCoverImageUrl(imgs[index])
            }else {
                let frame = CGRect(x: CGFloat(index) * ScreenWidth, y: 0, width: ScreenWidth, height: height)
                let imgView = UIImageView(frame: frame)
                imgView.contentMode = .scaleAspectFit
                imgView.setCoverImageUrl(imgs[index])
                scrollView.add(imgView)
            }
        }
    }
}

extension HotFoundImageCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.dzy_ofx / ScreenWidth)
        pageLB.text = "\(index + 1)/\(imgCount)"
    }
}

extension HotFoundImageCell: HotFoundCellUIProtocol {
    var p_nameLB: UILabel? {
        return nameLB
    }
    
    var p_briefLB: UILabel? {
        return briefLB
    }
    
    var p_logoIV: UIImageView? {
        return logoIV
    }
    
    var p_contentLB: UILabel? {
        return contentLB
    }
    
    var p_lookNumLB: UILabel? {
        return lookNumLB
    }
    
    var p_commentLB: UILabel? {
        return commentLB
    }
    
    var p_topCommentLB: UILabel? {
        return topCommentLB
    }
    
    var p_bottomCommentLB: UILabel? {
        return bottomCommentLB
    }
    
    var p_commentHLC: NSLayoutConstraint? {
        return commentHLC
    }
}

