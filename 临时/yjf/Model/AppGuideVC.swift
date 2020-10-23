//
//  AppGuideVC.swift
//  YJF
//
//  Created by edz on 2019/8/8.
//  Copyright © 2019 灰s. All rights reserved.
//

import UIKit

class AppGuideVC: BaseVC {
     
     private var totalNum: Int = 3
     
     private var imgName: String = "app_guide_"
     
     var jumpHandler: (()->())?
     
     @IBOutlet weak var stackView: UIStackView!
     
     override func viewDidLoad() {
          super.viewDidLoad()
          initUI()
     }
     
     override func viewWillAppear(_ animated: Bool) {
          self.navigationController?.setNavigationBarHidden(true, animated: true)
          super.viewWillAppear(animated)
     }
     
     private func initUI() {
          (0...totalNum).forEach { (index) in
               let height = String(format: "%.0lf", ScreenHeight)
               let imageName = imgName + height + "_" + "\(index)"
               UIImage(contentsOfFile: dzy_imgPath(imageName))
                    .flatMap(UIImageView.init)
                    .map({
                         $0.snp.makeConstraints({ (make) in
                              make.width.equalTo(ScreenWidth)
                         })
                         stackView.addArrangedSubview($0)
                    })
          }
          if let scrollView = stackView.superview as? UIScrollView {
               scrollView.addSubview(jumpBtn)
          }
     }
     
     @objc private func jumpAction() {
          jumpHandler?()
     }
     
     //     MARK: - 懒加载
     private lazy var jumpBtn: UIButton = {
          let btn = UIButton(type: .custom)
          btn.addTarget(self, action: #selector(jumpAction), for: .touchUpInside)
          btn.frame = CGRect(
               x: CGFloat(totalNum - 1) * ScreenWidth,
               y: 0,
               width: ScreenWidth,
               height: ScreenHeight
          )
          return btn
     }()
}
