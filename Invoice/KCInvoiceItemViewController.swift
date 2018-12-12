//
//  KCInvoiceItemViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 12/12/2018.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCInvoiceItemViewController : UIViewController {
    
    @IBOutlet weak var itemCode : UITextField!
    @IBOutlet weak var itemDesc : UITextField!
    @IBOutlet weak var unitPrice : UITextField!
    @IBOutlet weak var qty : UITextField!
    @IBOutlet weak var amount : UITextField!
    
    var selectedId : Int32 = 0
    
    let dbInstance = KCDBUtility()
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let util = KCUtility()
        
        if (self.selectedId > 0) {
            var insertSql = "insert into invoice_item_table (invoice_id, item_code, item_desc, unit_price, qty, amount, create_time) values "
            insertSql += "(\(self.selectedId), '" + (itemCode.text)! + "', '"
            insertSql += (itemDesc.text)! + "', '" + (unitPrice.text)! + "', '"
            insertSql += (qty.text)! + "', '" + (amount.text)! + "', '"
            insertSql += util.getTodayStr() + "')"
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert invoice item=\(result)")
        }
        
        self.dismiss(animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    override func viewDidLoad() {
        
        let util = KCUtility()
        
        
    }
    
}
