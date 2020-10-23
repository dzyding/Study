//
//  CheckOutVC.swift
//  PPBody
//
//  Created by edz on 2019/1/14.
//  Copyright © 2019 Nathan_he. All rights reserved.
//

import UIKit

class CheckOutVC: UIViewController {
    
    weak var personalVC: PersonalVC?
    
    @IBOutlet weak var inputTF: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        inputTF.delegate = self
        (1...183).forEach { (i) in
            let num = String(format: "%03d", i)
            let account = "pp" + num
            data.append(account)
        }
        data += [ "18782855132","13276794047","15083873178","13172629882","18204971056","13538049275","13099078202","13088458434","13136799822","17623711180","13232304634","13705374294","13682933872","18477588532","15574003851","13936763461","15133703511","13532786542","15336098647","15047525346","13682122900","15969483194","13404866961","18519205135","15938652073","13970241626","18171819814","18703730524","15678472763","17635591630","15557549095","15658704941","15873542942","17665295599","13964671750","18639044629","18856626919","15705002246","13230672756","13221938419","13982577187","17374814553","18570683042","13547108205","18552550739","18783092064","13569975365","15512259019","13619644024","13637659541","18077044186","15736596121","17776320546","18582582851","13453615968","13471442373","15866930331","16609557265","13173748337","13812413639","15939146257","15354202679","13703314248","18845028892","18674007175","13951539329","13783923272","17393773699","18438743307","18647605460","15622500709","13678006153","15958748607","15807174225","15071859579","17671205137","15172885476","13886551101","18926862470","13419688168","18942978996","13059426788","17671183646","15172871192","13687194059","13596370193","13846549448","18695203849","15666885272","15172887018","18864983971","19931599640","13245142915","15759959217","17390610703","15016880767","18838540692","18762856535","18177197523","15152240476","13702307739","15289561574","15665746203","17620015203","13287727896","17711764986","18534717535","15885741790","16692396365","15114520936","15924479029","15135502426","15353602876","13870055941","15124950006","13169958993","13134815866","15057601376","13557239894","18376874312","17712740126","13255204325","17797645796","13211512230","15093730351","17376045935","15770998310","15626908995","13231826360","15843653877","13590057594","18478199050","13782375000","18995628826","18871603644","18871648337","13027150631","15776357702","13671056375","15939174095","18806835053","13222092133","13060556623","18600011777","13801585531","13678006153","15958748607","15807174225","13886551101","17671205137","15071859579","15172885476","13059426788","18942978996","13419688168","18926862470","15172871192","13687194059","13596370193","18695203849","13846549448","15666885272","15172887018","18864983971","19931599640","17390610703","15759959217","13245142915","15016880767"
        ]
        tableView.reloadData()
    }
    
    func loginAPI(_ account: String) {
        let request = BaseRequest()
        request.dic = [
            "mobile" : account,
            "password" : ToolClass.md5("123456" + "PPBody")
        ]
        request.url = BaseURL.Login
        request.start { (data, error) in
            guard error == nil else {
                dzy_log(error!)
                ToolClass.showToast(error!, .Failure)
                return
            }
            let user = data!["user"] as! [String:Any]
            DataManager.saveUserInfo(user)
            self.personalVC?.updateUserInfo()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        dzy_log("销毁")
    }
}

extension CheckOutVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = data[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataManager.logout()
        loginAPI(data[indexPath.row])
    }
}

extension CheckOutVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else {return false}
        if text.count == range.location {
            // 输入字符
            let final = text + string
            if let row = data.firstIndex(where: {$0.contains(final)}) {
                tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: false)
            }
        }else {
            // 删除字符 (count = location + 1)
            text.removeLast()
            if let row = data.firstIndex(where: {$0.contains(text)}) {
                tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: false)
            }
        }
        return true
    }
}
