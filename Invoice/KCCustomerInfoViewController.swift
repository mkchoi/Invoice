//
//  KCCustomerInfoViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/13/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCCustomerInfoViewController : UIViewController {

    @IBOutlet weak var customerName : UITextField!
    @IBOutlet weak var customerAddress : UITextField!
    @IBOutlet weak var customerTitle : UILabel!
    
    var selectedId: Int32 = 0
    
    let dbInstance = KCDBUtility()
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let util = KCUtility()
        
        if let customerNameText = self.customerName.text, customerNameText.isEmpty
        {
            // create the alert
            let alert = UIAlertController(title: "錯誤", message: "請輸入客戶名稱", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        var hasData = false
        var id : String = ""
        
        if (self.selectedId == 0) {
            let querySql = "select id from customer_table where customer_name='" + (customerName.text)! + "'"
            
            if let queryResult = dbInstance.querySQL(sql: querySql) {
                
                for row in queryResult {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        hasData = true
                        id = String(describing: num)
                    }
                }
            }
        } else {
            hasData = true
            id = String(describing: self.selectedId)
        }
        
        if (hasData) {
            print("hasData")
            var updateSql = "update customer_table set customer_name='" + (customerName.text)! + "', "
            updateSql += "address='" + (customerAddress.text)! + "', create_time='" + util.getTodayStr() + "' "
            updateSql += "where id=" + id
            
            let result = dbInstance.executeSQL(sql: updateSql)
            print("update customer info=\(result)")
            
            
        } else {
            var insertSql = "insert into customer_table (customer_name, address, create_time) values ('"
            insertSql += (customerName.text)! + "', '" + (customerAddress.text)! + "', '"
            insertSql += util.getTodayStr() + "')"
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert customer info=\(result)")
            
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (self.selectedId > 0) {
            self.customerTitle.text = "修改客戶資料"
            
            let querySql = "select id, customer_name, address from customer_table where id=\(self.selectedId)"
            print("query customer_table")
            
            if let queryResult = dbInstance.querySQL(sql: querySql) {
                
                for row in queryResult {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        customerName.text = (row["customer_name"] as? String)!
                        customerAddress.text = (row["address"] as? String)!
                        
                    }
                    
                }
            }
            print("query end")
        }
    }
    
}
