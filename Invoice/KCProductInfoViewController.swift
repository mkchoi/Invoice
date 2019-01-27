//
//  KCProductInfoViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/21/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCProductInfoViewController : UIViewController {
    
    @IBOutlet weak var productCode : UITextField!
    @IBOutlet weak var productName : UITextField!
    @IBOutlet weak var unitPrice : UITextField!
    @IBOutlet weak var productUnit : UITextField!
    @IBOutlet weak var productTitle : UILabel!
    
    var selectedId: Int32 = 0
    
    let dbInstance = KCDBUtility()
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let util = KCUtility()
        
        var hasData = false
        var id : String = ""
        
        if (self.selectedId == 0) {
            let querySql = "select id from product_table where item_code='" + (productCode.text)! + "'"
        
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
            var updateSql = "update product_table set item_code='" + (productCode.text)! + "', "
            updateSql += "item_desc='" + (productName.text)! + "', item_unit='" + (productUnit.text)! + "', "
            updateSql += "unit_price='" + (unitPrice.text)! + "', create_time='" + util.getTodayStr() + "' "
            updateSql += "where id=" + id
            
            let result = dbInstance.executeSQL(sql: updateSql)
            print("update product info=\(result)")
            
            
        } else {
            var insertSql = "insert into product_table (item_code, item_desc, item_unit, unit_price, create_time) values ('"
            insertSql += (productCode.text)! + "', '" + (productName.text)! + "', '" + (productUnit.text)! + "', '"
            insertSql += (unitPrice.text)! + "', '" + util.getTodayStr() + "')"
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert product info=\(result)")
            
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (self.selectedId > 0) {
            self.productTitle.text = "修改貨品"
            
            let querySql = "select id, item_code, item_desc, item_unit, unit_price from product_table where id=\(self.selectedId)"
            print("query product_table")
            
            if let queryResult = dbInstance.querySQL(sql: querySql) {
                
                for row in queryResult {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        productCode.text = (row["item_code"] as? String)!
                        productName.text = (row["item_desc"] as? String)!
                        productUnit.text = (row["item_unit"] as? String)!
                        unitPrice.text = String(describing: (row["unit_price"] as? Double)!)
                        
                    }
                    
                }
            }
            print("query end")
        }
    }
    
}
