//
//  KCCompanyInfoViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/4/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCCompanyInfoViewController : UIViewController {
    
    @IBOutlet weak var companyName : UITextField!
    @IBOutlet weak var companyAddress : UITextField!
    @IBOutlet weak var companyTel : UITextField!
    @IBOutlet weak var companyEmail : UITextField!
    
    
    let dbInstance = KCDBUtility()
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let util = KCUtility()
        
        var hasData = false
        var id : String = ""
        
        let querySql = "select id from company_table"
        
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
            var updateSql = "update company_table set company_name='" + (companyName.text)! + "', "
            updateSql += "address='" + (companyAddress.text)! + "', tel='" + (companyTel.text)! + "', "
            updateSql += "email='" + (companyEmail.text)! + "', create_time='" + util.getTodayStr() + "' "
            updateSql += "where id=" + id
            
            let result = dbInstance.executeSQL(sql: updateSql)
            print("update company info=\(result)")
            
            
        } else {
            var insertSql = "insert into company_table (company_name, address, tel, email, create_time) values ('"
            insertSql += (companyName.text)! + "', '" + (companyAddress.text)! + "', '"
            insertSql += (companyTel.text)! + "', '" + (companyEmail.text)! + "', '"
            insertSql += util.getTodayStr() + "')"
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert company info=\(result)")
            
        }
    
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let querySql = "select id, company_name, address, tel, email from company_table"
        print("query company_table")
        
        if let queryResult = dbInstance.querySQL(sql: querySql) {
            
            for row in queryResult {
                if let num = row["id"] {
                    print("id=\(num)")
  
                    companyName.text = (row["company_name"] as? String)!
                    companyAddress.text = (row["address"] as? String)!
                    companyTel.text = (row["tel"] as? String)!
                    companyEmail.text = (row["email"] as? String)!
                        
                }
                
            }
        }
        print("query end")
    }
}
