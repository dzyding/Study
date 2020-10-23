//
//  CameraLibraryProtocol.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/2/23.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

protocol CameraLibraryProtocol {
    func photoOrLibrary()
}

extension CameraLibraryProtocol where Self: UIViewController, Self: UIImagePickerControllerDelegate, Self: UINavigationControllerDelegate  {
    ///选择图片的sheet
    func photoOrLibrary() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "相机", style: .default) { [unowned self] (action) in
            self.photoUpLoad()
        }
        action1.setTextColor(Dzy_MainColor)
        let action2 = UIAlertAction(title: "相册", style: .default) { [unowned self] (action) in
            self.libraryUpLoad()
        }
        action2.setTextColor(Dzy_MainColor)
        let action3 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        action3.setTextColor(Dzy_MainColor)
        sheet.addAction(action1)
        sheet.addAction(action2)
        sheet.addAction(action3)
        self.tabBarController?.present(sheet, animated: true, completion: nil)
    }
    
    fileprivate func photoUpLoad() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self.tabBarController?.present(picker, animated: true, completion: nil)
        }else {
            let alert = dzy_msgAlert("提示", msg: "相机不可用")
            present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func libraryUpLoad() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.tabBarController?.present(picker, animated: true, completion: nil)
    }
}
