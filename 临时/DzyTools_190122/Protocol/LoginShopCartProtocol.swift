//
//  LoginShopCartProtocol.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/3/19.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation

protocol LoginShopCartProtocol where Self: UIViewController {
    func checkLocalProduct()
}

extension LoginShopCartProtocol {
    //    MARK: - 本地购物车合并到当前购物车
    func checkLocalProduct() {
        if let arr = ShopCartListModel.unarchive() {
            let par = arr.map({$0.addDict ?? [:]})
            self.addLocalProduct(par)
        }else {
            login_okNext()
        }
    }
    
    //将本地数据加入到购物车
    func addLocalProduct(_ par: [[String : Any]]) {
        Cart.addsOperation(par, result: { (model) in
            if let model = model, model.code == 200 {
                ShopCartListModel.cleanArchive()
            }
            self.login_okNext()
        })
    }
    
    func login_okNext() {
        //刷新tabbar的购物车数量
        shopCartCountUpdate()
        dismiss(animated: true, completion: nil)
        dzy_success("登录成功")
    }
}
