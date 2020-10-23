//
//  RegisterMobileView.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/25.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class RegisterMobileView: UIView
{
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var userProBtn: UIButton!
    @IBOutlet weak var secretProBtn: UIButton!
    
    var userProHandler: (()->())?
    
    var secretProHandler: (()->())?
    
    class func instanceFromNib() -> RegisterMobileView {
        return UINib(nibName: "RegisterProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RegisterMobileView
    }
    
    override func awakeFromNib() {
        mobileTF.setPlaceholderColor(Text1Color)
        codeTF.setPlaceholderColor(Text1Color)
        userProBtn.addUnderLineStyle()
        if let text = secretProBtn.attributedTitle(for: .normal) {
            let temp = NSMutableAttributedString(attributedString: text)
            temp.addAttributes([
                .underlineStyle : NSUnderlineStyle.single.rawValue
                ], range: NSRange(location: 2,
                                  length: temp.length - 2)
            )
            secretProBtn.setAttributedTitle(temp, for: .normal)
        }
        mobileTF.becomeFirstResponder()
    }
    
    @IBAction func userProtocolAction(_ sender: UIButton) {
        userProHandler?()
    }
    
    @IBAction func secretProtocolAction(_ sender: Any) {
        secretProHandler?()
    }
    
    
    func getMobileDic() -> [String:String]? {
        guard let text = mobileTF.text,
            ToolClass.checkPhone(text) else
        {
            ToolClass.showToast("手机号不正确", .Failure)
            return nil
        }
        var dic: [String : String] = ["mobile" : text]
        if let code = codeTF.text,
            !code.isEmpty
        {
            dic["invite"] = code
        }
        return dic
    }
}
