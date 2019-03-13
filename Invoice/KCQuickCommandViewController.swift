//
//  KCQuickCommandViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 3/2/19.
//  Copyright © 2019 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCQuickCommandViewController : UIViewController {
    
    @IBOutlet weak var command : UITextField!
    
    let dbInstance = KCDBUtility()
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if (command.text == "reset") {
            dbInstance.resetDB()
            
        } else if (command.text == "laoshanhang") {
            dbInstance.initLaoShanHang()
            
        } else if (command.text == "demo") {
            dbInstance.initDemo()
            
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
}
