//
//  PrivateTrainDetailVC.swift
//  PPBody
//
//  Created by Mike on 2018/6/29.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import UIKit

class PrivateTrainDetailVC: BaseVC {
    
    @IBOutlet weak var tableList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableList.register(UINib.init(nibName: "PrivateTrainDetailCell", bundle: nil), forCellReuseIdentifier: "PrivateTrainDetailCell")
      
        // Do any additional setup after loading the view.
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


extension PrivateTrainDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateTrainDetailCell", for: indexPath) as! PrivateTrainDetailCell
        cell.selectionStyle = .none
        return cell
    }
    
    
}
