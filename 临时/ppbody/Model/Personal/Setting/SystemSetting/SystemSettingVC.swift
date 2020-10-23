//
//  SystemSettingVC.swift
//  PPBody
//
//  Created by Mike on 2018/7/9.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class SystemSettingVC: BaseVC {

    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var lblCache: UILabel!
    @IBOutlet weak var clearView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "系统设置"
        clearView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapView)))
        lblCache.text = "\(fileSizeOfCache())M"
        
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        self.versionLbl.text = "V" + currentVersion
        
    }
    
    @objc func tapView() {
        let alert = UIAlertController.init(title: "请确认是否删除缓存？", message: "", preferredStyle: .alert)
        let actionN = UIAlertAction.init(title: "是", style: .default) { (_) in
            self.clearCache()            
            self.lblCache.text = "0M"
        }
        
        let actionY = UIAlertAction.init(title: "否", style: .cancel) { (_) in
            
        }
        alert.addAction(actionN)
        alert.addAction(actionY)
        self.present(alert, animated: true, completion: nil)
    }
    
    //缓存文件大小
    func fileSizeOfCache()-> Int {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

        // 取出文件夹下所有文件数组
        
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        
        //快速枚举出所有文件名 计算文件大小
        
        var size = 0
        
        for file in fileArr! {
            
            // 把文件名拼接到路径中
            
            let path = (cachePath! as NSString).appending("/\(file)")
            
            // 取出文件属性
            
            let floder = try! FileManager.default.attributesOfItem(atPath: path)
            
            // 用元组取出文件大小属性
            
            for (abc, bcd) in floder {
                
                // 累加文件大小
                
                if abc == FileAttributeKey.size {
                    
                    size += (bcd as AnyObject).integerValue
                    
                }
            }
        }
        
        let mm = size / 1024 / 1024
        return mm
    }
    
    func clearCache() {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        // 取出文件夹下所有文件数组
        
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        
        // 遍历删除
        
        for file in fileArr! {
            
            let path = (cachePath! as NSString).appending("/\(file)")
            
            if FileManager.default.fileExists(atPath: path) {
                
                do {
                    try FileManager.default.removeItem(atPath: path)
                    
                } catch {
                    
                    
                }
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
