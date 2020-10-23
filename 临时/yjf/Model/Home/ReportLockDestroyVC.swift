//
//  ReportLockDestroyVC.swift
//  YJF
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit
import DzyImagePicker
import ZKProgressHUD

enum ReportLockType {
    /// 房源详情
    case detail
    /// 看房
    case watch
}

class ReportLockDestroyVC: BaseVC, CustomBackProtocol {
    
    private let imageSize = PublicConfig.sysConfigIntValue(.imageSize) ?? 200
    
    private let maxNum = PublicConfig.sysConfigIntValue(.look_report_imageNum) ?? 3
    
    private let houseId: Int
    
    private let type: ReportLockType
    
    @IBOutlet weak var placeHolderLB: UILabel!
    
    private var lrPadding: CGFloat = 18.0
    
    private var padding: CGFloat = 5.0
    
    private var itemWidth: CGFloat {
        return collectionViewHLC.constant
    }

    @IBOutlet weak var collectionViewHLC: NSLayoutConstraint!
    
    @IBOutlet weak var inputTV: UITextView!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var sureBtn: UIButton!
    
    private var imgs: [UIImage] = []
    
    init(_ houseId: Int, type: ReportLockType) {
        self.houseId = houseId
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "报告门锁故障"
        sureBtn.layer.borderWidth = 1
        sureBtn.layer.borderColor = MainColor.cgColor
        collectionView.dzy_registerCellFromNib(AddImageCell.self)
        let constant = (ScreenWidth - 2 * (lrPadding + padding)) / 3.0
        collectionViewHLC.constant = constant
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        dzy_pop()
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        var dic: [String : Any] = [
            "houseId": houseId
        ]
        guard let input = inputTV.text, input.count > 0 else {
            showMessage("请输入说明")
            return
        }
        dic["content"] = input
        if imgs.count > 0 {
            ZKProgressHUD.show()
            changeImgsToUrl { [weak self] (urls) in
                ZKProgressHUD.dismiss()
                dic["lockImgs"] = ToolClass.toJSONString(dict: urls)
                self?.reportLockApi(dic)
            }
        }else {
            reportLockApi(dic)
        }
    }
    
    //    MARK: - 上传图片
    private func changeImgsToUrl(_ complete: @escaping ([String])->()) {
        var result = [String](repeating: " ", count: imgs.count)
        let group = DispatchGroup()
        
        func updateImageToUrl(_ image: UIImage, index: Int) {
            group.enter()
            let data = ToolClass.resetSizeOfImageData(
                source_image: image, maxSize: imageSize
            )
            PublicFunc.bgUploadApi(data, success: { (imgUrl) in
                let url = imgUrl ?? ""
                result[index] = url
                group.leave()
            })
        }
        imgs.enumerated().forEach { (index, image) in
            updateImageToUrl(image, index: index)
        }
        group.notify(queue: DispatchQueue.main) {
            complete(result)
        }
    }
    
    //    MARK: - api
    private func reportLockApi(_ dic: [String : Any]) {
        let request = BaseRequest()
        request.url = BaseURL.reportLock
        request.dic = dic
        request.isUser = true
        request.dzy_start { (data, _) in
            if data != nil {
                self.showMessage("提交成功")
                if self.type == .watch {
                    self.dzy_removeChildVCs([WatchHouseVC.self])
                }
                self.dzy_pop()
            }
        }
    }
}

extension ReportLockDestroyVC:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(imgs.count + 1, maxNum)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dzy_dequeueCell(AddImageCell.self, indexPath)
        if indexPath.row < imgs.count {
            cell?.updateUI((imgs[indexPath.row], nil), indexPath: indexPath)
        }else {
            cell?.updateUI(nil, indexPath: indexPath)
        }
        cell?.delegate = self
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == imgs.count {
            let max = maxNum - imgs.count
            let imagePicker = DzyImagePickerVC(.origin(.several(max)))
            imagePicker.delegate = self
            present(BaseNavVC(rootViewController: imagePicker),
                    animated: true,
                    completion: nil)
        }else {
            let showView = DzyShowImageView(.image(imgs[indexPath.row]))
            showView.show()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return padding
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return padding
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

extension ReportLockDestroyVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLB.isHidden = textView.text.count > 0
    }
}

extension ReportLockDestroyVC: DzyImagePickerVCDelegate {
    func imagePicker(_ picker: DzyImagePickerVC?, getCropImage image: UIImage) {}
    
    func imagePicker(_ picker: DzyImagePickerVC?, getOriginImage image: UIImage) {}
    
    func selectedFinshAndBeginDownload(_ picker: DzyImagePickerVC?) {}
    
    func imagePicker(_ picker: DzyImagePickerVC?, getImages imgs: [UIImage]) {
        self.imgs += imgs
        collectionView.reloadData()
    }
}

extension ReportLockDestroyVC: AddImageCellDelegate {
    func imageCell(_ imageCell: AddImageCell, didClickDelBtn btn: UIButton) {
        if let index = imageCell.indexPath?.row {
            imgs.remove(at: index)
            collectionView.reloadData()
        }
    }
}
