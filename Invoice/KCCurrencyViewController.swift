//
//  KCCurrencyViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 2/8/19.
//  Copyright © 2019 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCCurrencyViewController : UIViewController {

    @IBOutlet weak var currencyUnit : UITextField!
    
    let dbInstance = KCDBUtility()
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let util = KCUtility()
        
        var hasData = false
        var id : String = ""
        
        let querySql = "select id from currency_table"
        
        if let queryResult = dbInstance.querySQL(sql: querySql) {
            
            for row in queryResult {
                if let num = row["id"] {
                    print("id=\(num)")
                    
                    hasData = true
                    id = String(describing: num)
                }
            }
        }
        
        if (hasData) {
            print("hasData")
            var updateSql = "update currency_table set currency_unit='" + (currencyUnit.text)! + "', "
            updateSql += "create_time='" + util.getTodayStr() + "' "
            updateSql += "where id=" + id
            
            let result = dbInstance.executeSQL(sql: updateSql)
            print("update currency info=\(result)")
            
            
        } else {
            var insertSql = "insert into currency_table (currency_unit, create_time) values ('"
            insertSql += (currencyUnit.text)! + "', '"
            insertSql += util.getTodayStr() + "')"
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert currency info=\(result)")
            
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let querySql = "select id, currency_unit from currency_table"
        print("query currency_table")
        
        if let queryResult = dbInstance.querySQL(sql: querySql) {
            
            for row in queryResult {
                if let num = row["id"] {
                    print("id=\(num)")
                    
                    currencyUnit.text = (row["currency_unit"] as? String)!
                    
                }
                
            }
        }
        print("query end")
    }
}
