//
//  GiftPopView.swift
//  PPBody
//
//  Created by edz on 2018/12/8.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

protocol GiftPopViewDelegate: NSObjectProtocol {
    // 前往钱包
    func gotoWallet()
    // 赠送礼物
    func sendAction(rentS: CGRect, image: UIImage, count: Int, giftID: Int)
}

class GiftPopView: UIView {
    
    /// 正好一个半 item 的高度，加上底部视图的高度
    static let collectionHeight: CGFloat = ((ScreenWidth - 35.0) / 4.0) * 1.5
    
    static let height: CGFloat = GiftPopView.collectionHeight + 50.0
    
    @IBOutlet weak var collectionHeightLC: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    /// 主vc 中
    weak var parentVCView: UIView?
    /// 礼物数量
    @IBOutlet weak var numTF: UITextField!
    /// 汗水
    @IBOutlet weak var sweatLB: UILabel!
    
    weak var delegate: GiftPopViewDelegate?
    /// 选择数量的按钮
    @IBOutlet weak var selectNumBtn: UIButton!
    /// 现在数量的视图
    var numView: GiftNumView?
    /// 选择数量视图的背景透明视图
    var numpop: UIView?
    /// 开启或关闭数字选择的小箭头
    @IBOutlet weak var upIV: UIImageView!
    
    var dataArr: [[String : Any]] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionHeightLC.constant = GiftPopView.collectionHeight
        collectionView.dzy_registerCellFromNib(GiftPopCell.self)
        
        selectNumBtn.layer.borderWidth = 1
        selectNumBtn.layer.borderColor = YellowMainColor.cgColor
        
        let inputView = GiftInputNumView.initFromNib(GiftInputNumView.self)
        inputView.handler = { [weak self] num in
            self?.inputSureAction(num)
        }
        numTF.inputAccessoryView = inputView
        numTF.keyboardAppearance = .dark
        
        sweatLB.text = "\(DataManager.getSweat())"
        
        giftsApi()
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] (_) in
            if let tf = self?.numTF.inputAccessoryView as? GiftInputNumView {
                tf.inputTF.becomeFirstResponder()
            }
        }
    }
    
    /// 更改本地记录
    func changeSwaet(_ count: Int, _ giftID: String) {
        if let ID = Int(giftID),
            let value = dataArr.filter({$0.intValue("id") == ID}).first?.intValue("value")
        {
            var sweat = DataManager.getSweat()
            sweat += (count * value)
            DataManager.changeSweat(sweat)
            sweatLB.text = "\(sweat)"
        }
    }
    
    //    MARK: - 获取礼物列表
    func giftsApi() {
        let request = BaseRequest()
        request.url = BaseURL.Gifts
        request.start { [weak self] (data, error) in
            guard error == nil else {
                ToolClass.showToast(error!, .Failure)
                return
            }
            if var list = data?["list"] as? [[String : Any]] {
                (0..<list.count).forEach({ (index) in
                    list[index].updateValue(false, forKey: "selected")
                })
                self?.dataArr = list
                self?.collectionView.reloadData()
            }
        }
    }
    
    //    MARK: - 发送
    @IBAction func baseSendAction(_ sender: Any) {
        guard let gift = dataArr.filter({ dict -> Bool in
            return dict.boolValue("selected") == true
        }).first else {
            ToolClass.showToast("请选择礼物", .Failure)
            return
        }
        guard let countStr = numTF.text, let count = Int(countStr) else {
            ToolClass.showToast("请选择数量", .Failure)
            return
        }
        guard let value = gift.intValue("value"), value * count <= DataManager.getSweat() else {
            ToolClass.showToast("汗水值不足", .Failure)
            return
        }
        
        if let view = parentVCView,
            let index = dataArr.firstIndex(where: {$0.boolValue("selected") == true}),
            let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? GiftPopCell,
            let rectS = collectionView?.convert(cell.frame, to: view),
            let image = cell.imgView.image
        {
            let radiusImage = image.kf.image(withRoundRadius: UI_W(30), fit: CGSize(width: UI_W(60), height: UI_W(60)))
            if let giftID = gift.intValue("id") {
                delegate?.sendAction(rentS: rectS, image: radiusImage, count: count, giftID: giftID)
            }else {
                ToolClass.showToast("请选择礼物", .Failure)
            }
        }
    }
    
    //    MARK: - 前往钱包
    @IBAction func baseGoToWallet(_ sender: Any) {
        delegate?.gotoWallet()
    }
    
    func upIVAnimate(_ open: Bool) {
        if open {
            UIView.animate(withDuration: 0.3) {
                self.upIV.transform = self.upIV.transform.rotated(by: CGFloat(Double.pi))
            }
        }else {
            UIView.animate(withDuration: 0.3) {
                self.upIV.transform = CGAffineTransform.identity
            }
        }
    }
    
    //    MARK: - 选择数量
    @IBAction func selectNumAction(_ sender: UIButton) { //这个方法其实只负责显示
        upIVAnimate(true)
        if let numpop = numpop {
            if numView?.superview == nil {
                numpop.addSubview(numView!)
            }
            parentVCView?.addSubview(numpop)
        }else {
            guard let parentVCView = parentVCView else {return}
            numView = GiftNumView.initFromNib(GiftNumView.self)
            numView?.delegate = self
            let btnFrame = convert(selectNumBtn.frame, to: parentVCView)
            numView?.frame = CGRect(x: btnFrame.midX - (GiftNumView.size.width / 2.0),
                                    y: btnFrame.minY - 10 - GiftNumView.size.height,
                                    width: GiftNumView.size.width, height: GiftNumView.size.height)
            
            numpop = UIView(frame: parentVCView.bounds)
            numpop?.backgroundColor = .clear
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(hideNumView(_:)))
            tap.delegate = self
            numpop?.addGestureRecognizer(tap)
            
            numpop?.addSubview(numView!)
            parentVCView.addSubview(numpop!)
        }
    }
    
    //MARK: - numView 对应的背景view 点击事件
    @objc func hideNumView(_ tap: UITapGestureRecognizer) {
        // 等于 0 的时候，就是点击自定义以后，直接点击背景
        if let count = tap.view?.subviews.count, count == 0 {
            if let tf = numTF.inputAccessoryView as? GiftInputNumView {
                tf.inputTF.resignFirstResponder()
            }
            parentVCView?.endEditing(true)
        }
        numpop?.removeFromSuperview()
        upIVAnimate(false)
    }
    
    //    MARK: - inputView 的确定按钮
    @objc func inputSureAction(_ num: String) {
        numTF.text = num
        numpop?.removeFromSuperview()
        parentVCView?.endEditing(true)
        upIVAnimate(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        dzy_log("deinit")
    }
}

//MARK: - GiftNumViewDelegate
extension GiftPopView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // tableView 的 selectCell 和 tap 有冲突
        guard let tap = gestureRecognizer as? UITapGestureRecognizer else {return true}
        let point = tap.location(in: tap.view)
        if let nv = tap.view?.subviews.first,
            nv.frame.contains(point)
        {
            return false
        }
        return true
    }
}

//MARK: - GiftNumViewDelegate
extension GiftPopView: GiftNumViewDelegate {
    //MARK: - 选中默认提供的数字(1, 88, 888 这些)
    func selectNum(_ num: String) {
        numpop?.removeFromSuperview()
        numTF.text = num
        upIVAnimate(false)
    }
    
    //MARK: - 点击自定义
    func diyNum() {
        // 这个时候只需要把 numView 移除，bg 还需要留着，可能会用于点击隐藏
        numView?.removeFromSuperview()
        numTF.becomeFirstResponder()
    }
}

extension GiftPopView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dzy_dequeueCell(GiftPopCell.self, indexPath)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GiftPopCell {
            cell.data = dataArr[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let x = (ScreenWidth - 35.0) / 4.0
        return CGSize(width: x, height: x)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (0..<dataArr.count).forEach({dataArr[$0].updateValue(false, forKey: "selected")})
        dataArr[indexPath.row].updateValue(true, forKey: "selected")
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}
