//
//  SearchVC.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/31.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class SearchVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var searchTF: UITextField!
    var isReload = false
    
    let searchPersonalVC = SearchPersonalVC(itemInfo: "用户")
    let searchTopicTagVC = SearchTopicTagVC(itemInfo: "话题")
    
    var key:String?
    
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarLeftContentInset = 50
        settings.style.buttonBarRightContentInset = 50
        
        settings.style.selectedBarBackgroundColor = YellowMainColor
        
        super.viewDidLoad()
        
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: Text1Color])
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = Text1Color
            newCell?.label.textColor = YellowMainColor
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            } else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        
        
        if key != nil && !(key?.isEmpty)!
        {
            searchTF.text = key!
            searchPersonalVC.startSearch(key!)
            searchTopicTagVC.startSearch(key!)
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        
        guard isReload else {
            return [searchPersonalVC, searchTopicTagVC]
        }
        
        var childViewControllers = [searchPersonalVC, searchTopicTagVC]
        
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
    @IBAction func cancel(_ sender: UIButton) {
        super.backAction()
    }
}

extension SearchVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text?.isEmpty)!
        {
            self.key = textField.text!
            searchPersonalVC.startSearch(key!)
            searchTopicTagVC.startSearch(key!)
            DataManager.saveHistorySearch(textField.text!)

        }
        
        return true
    }
}
