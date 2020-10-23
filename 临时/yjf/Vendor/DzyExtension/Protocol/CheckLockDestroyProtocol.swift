//
//  CheckLockDestroyProtocol.swift
//  YJF
//
//  Created by edz on 2019/10/23.
//  Copyright © 2019 灰s. All rights reserved.
//

protocol CheckLockDestroyProtocol {
    func isLockCanUse(_ house: [String : Any]) -> Bool
}
 
extension CheckLockDestroyProtocol {
    func isLockCanUse(_ house: [String : Any]) -> Bool {
        guard let status = house.intValue("lockStatus") else {
            return false
        }
        return ![5, 10, 20, 25, 35, 40, 45, 50, 60].contains(status)
    }
    
    /*
    5.没有门锁押金  10.待安装  20.安装中（已生成对应任务）25.装锁失败(和10对等) 30.安装成功 35.待拆锁 40.拆锁中（已生成对应任务）45. 换锁中  50=10 (50 和 10可以理解成是一样的)
    */
}
