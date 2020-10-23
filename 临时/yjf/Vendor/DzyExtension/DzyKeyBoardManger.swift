//
//  DzyKeyBoardManger.swift
//  LengLian
//
//  Created by dzy_PC on 16/7/18.
//  Copyright © 2016年 LengMarlon. All rights reserved.
//

import UIKit

class DzyKeyBoardManger: NSObject {
    ///单例
    static let `default` = DzyKeyBoardManger()
    ///textField 或者 textView
    fileprivate var text: UIView?
    ///顶层VC
    fileprivate weak var rootViewController: UIViewController?
    ///判断键盘的开启状态
    fileprivate var isShow: Bool = false
    ///view的初始frame
    fileprivate var topViewBeginFrame: CGRect?
    ///移动的距离(这个好像没用，先留着吧)
    fileprivate var movedDistance : CGFloat = 0.0
    ///键盘的rect
    fileprivate var kbSize: CGSize = .zero
    ///临时存Notification textView的通知在willChange后面
    fileprivate var notice: Notification?
    
    private override init() {}
    
    ///开关
    var enable: Bool = false {
        didSet {
            if enable == true && oldValue == false {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyBoardWillChange(_:)),
                    name: UIResponder.keyboardWillChangeFrameNotification,
                    object: nil
                )
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyBoardDidHide(_:)),
                    name: UIResponder.keyboardDidHideNotification,
                    object: nil
                )
                registerTextFieldViewClass(
                    UITextField.self,
didBeginEditingNotificationName: UITextField.textDidBeginEditingNotification.rawValue,
didEndEditingNotificationName: UITextField.textDidEndEditingNotification.rawValue
                )
                registerTextFieldViewClass(
                    UITextView.self,
didBeginEditingNotificationName: UITextView.textDidBeginEditingNotification.rawValue,
didEndEditingNotificationName: UITextView.textDidEndEditingNotification.rawValue
                )
            }else if enable == false && oldValue == true {
                //swiftlint:disable:next notification_center_detachment
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    fileprivate func registerTextFieldViewClass(
        _ aClass: UIView.Type,
        didBeginEditingNotificationName : String,
        didEndEditingNotificationName : String
        )
    {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textDidBeginEditing(_:)),
            name: NSNotification.Name(rawValue: didBeginEditingNotificationName),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textDidEndEditing(_:)),
            name: NSNotification.Name(rawValue: didEndEditingNotificationName),
            object: nil
        )
    }
    
    //    MARK: - Getting keyWindow
    fileprivate func keyWindow() -> UIWindow? {
        
        if let keyWindow = text?.window {
            return keyWindow
        } else {
            
            struct Static {
                //避免UIApplication.shared.keyWindow == nil 的特殊情况
                static var keyWindow : UIWindow?
            }
            
            let originalKeyWindow = UIApplication.shared.keyWindow
            
            //如果keywindow变动了，则重新保存一份
            if originalKeyWindow != nil &&
                (Static.keyWindow == nil || Static.keyWindow != originalKeyWindow) {
                Static.keyWindow = originalKeyWindow
            }
            
            return Static.keyWindow
        }
    }
    
    @objc func keyBoardDidHide(_ noti:Notification) {
        //这个情况只有在没关闭键盘，直接pop控制器的时候会出现
        if text == nil && isShow == true {
            isShow = false
            topViewBeginFrame = nil
        }
    }
    
    @objc func keyBoardWillChange(_ noti:Notification) {
        //UITextView使用 TextView中keyBoardWillChange方法在textDidBeginEditing 之前
        notice = noti
        if let optext = text,
            optext.isAlertViewTextField() == false,
            optext.isSearchBarTextField() == false,
            let info = (noti as Notification).userInfo,
            let endValue = info["UIKeyboardFrameEndUserInfoKey"] as? NSValue
        {
            //更新frame
            let kbFrame = endValue.cgRectValue
            let screenSize = UIScreen.main.bounds
            
            //判断是否有相交
            let intersectRect = kbFrame.intersection(screenSize)
            
            if intersectRect.isNull {
                kbSize = CGSize(width: screenSize.size.width, height: 0)
            } else {
                kbSize = intersectRect.size
            }
            
            if kbSize.height == 0 && isShow {
                //关闭键盘
                operationEnd()
            }else {
                //刷新初始frame
                updateTopViewBeginFrame()
                adjustFrame()
            }
        }else {
            if isShow {
                if let topViewBeginFrame = topViewBeginFrame {
                    setRootViewFrame(topViewBeginFrame)
                }else {
                    setRootViewFrame(.zero)
                }
            }
        }
    }
    
    func updateTopViewBeginFrame() {
        if topViewBeginFrame == nil {
            if let topVC = text?.topMostController() {
                rootViewController = topVC
            }else {
                rootViewController = keyWindow()?.topMostWindowController()
            }
            //正常操作
            if let unwrappedRootController = rootViewController {
                topViewBeginFrame = unwrappedRootController.view.frame
                
                if unwrappedRootController is UINavigationController &&
                    unwrappedRootController.modalPresentationStyle != UIModalPresentationStyle.formSheet &&
                    unwrappedRootController.modalPresentationStyle != UIModalPresentationStyle.pageSheet
                {
                    if let window = keyWindow() {
                        let y = window.frame.size.height - unwrappedRootController.view.frame.size.height
                        topViewBeginFrame?.origin = CGPoint(x: 0, y: y)
                    } else {
                        topViewBeginFrame?.origin = .zero
                    }
                }
            } else {
                topViewBeginFrame = .zero
            }
        }
    }
    
    func adjustFrame() {
        guard let optext = text else {return}
        
        guard let window = keyWindow() else {return}
        
        guard let textFieldViewRect = optext.superview?.convert(optext.frame, to: window) else {return}
        
        guard let rootController = rootViewController else {return}
        
        guard let topViewBeginFrame = topViewBeginFrame else {return}
        
        var rootViewRect = rootController.view.frame
        
        //与键盘的距离
        let h = CGFloat(10.0)
        
        var kbSizeNow = kbSize
        kbSizeNow.height += h
        
        let statusBarFrame = UIApplication.shared.statusBarFrame
        
        let topLayoutGuide : CGFloat = statusBarFrame.height
        
        let move = min(textFieldViewRect.minY - (topLayoutGuide + 5),
                       textFieldViewRect.maxY - (window.frame.height - kbSizeNow.height))
        
        if move >= 0 {
            rootViewRect.origin.y -= move
            rootViewRect.origin.y = max(rootViewRect.origin.y, min(0, -kbSizeNow.height))
            //  Setting adjusted rootViewRect
            setRootViewFrame(rootViewRect)
            movedDistance = (topViewBeginFrame.origin.y - rootViewRect.origin.y)
        } else {  //  -Negative
            let disturbDistance : CGFloat = rootViewRect.minY - topViewBeginFrame.minY
            
            if disturbDistance < 0 {
                rootViewRect.origin.y -= max(move, disturbDistance)
                setRootViewFrame(rootViewRect)
                movedDistance = (topViewBeginFrame.origin.y - rootViewRect.origin.y)
            }
        }
    }
    
    fileprivate func operationEnd() {
        if let topViewBeginFrame = topViewBeginFrame {
            setRootViewFrame(topViewBeginFrame)
        }else {
            setRootViewFrame(.zero)
        }
        topViewBeginFrame = nil
        isShow = false
    }
    
    fileprivate func setRootViewFrame(_ frame: CGRect) {
        // 这里就这样写应该安全一些，比如没关键盘，直接返回，不知道window会不会变
        var controller = text?.topMostController()

        if controller == nil {
            controller = keyWindow()?.topMostWindowController()
        }
        
        if let unwrappedController = controller {
            var newFrame = frame
            //frame size needs to be adjusted on iOS8 due to orientation structure changes.
            newFrame.size = unwrappedController.view.frame.size
            //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { () -> Void in
                unwrappedController.view.frame = newFrame
            }) { (_) -> Void in}
        } else {  //  If can't get rootViewController then printing warning to user.
            
        }
    }
    
    @objc internal func textDidBeginEditing(_ notification:Notification) {
        text = notification.object as? UIView
        if text is UITextView {
            if let notice = notice {
                keyBoardWillChange(notice)
                self.notice = nil
            }
        }else if let textField = text as? UITextField {
            if textField.returnKeyType == .done {
                textField.addTarget(self, action: #selector(doneClick(_:)), for: .editingDidEndOnExit)
            }
            if textField.keyboardType == .decimalPad
                || textField.keyboardType == .numberPad
                || textField.keyboardType == .phonePad
            {
                textField.inputAccessoryView = getAccessoryView()
            }
        }
        
        //不关闭键盘，直接切换
        if isShow {
            adjustFrame()
        }
        
        //本来是写到willchange里面的，但是有个特殊情况，就是侧滑pop回上一个界面，然后取消掉pop，这个时候键盘是显示出来的，所以写在这里更保险
        isShow = true
    }
    
    @objc internal func textDidEndEditing(_ notification:Notification) {
        text = nil
    }
    
    func getAccessoryView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        view.backgroundColor = UIColor(red: 187.0/255.0, green: 194.0/255.0, blue: 201.0/255.0, alpha: 1)
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: ScreenWidth - 80, y: 5, width: 70, height: 30)
        btn.backgroundColor = .clear
        btn.setTitleColor(MainColor, for: .normal)
        btn.titleLabel?.font = dzy_Font(14)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = MainColor.cgColor
        btn.layer.cornerRadius = 3
        btn.setTitle("确定", for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        view.addSubview(btn)
        
        return view
    }
    
    @objc func doneClick(_ textField: UITextField) {
        
    }
    
    @objc func btnClick(){
        text?.resignFirstResponder()
    }
}
