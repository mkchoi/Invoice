//
//  KCInvoiceViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/29/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCInvoiceViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var invoiceNumber : UITextField!
    @IBOutlet weak var dateOfIssue : UITextField!
    @IBOutlet weak var billedTo : UITextField!
    @IBOutlet weak var billedToAddress : UITextView!
    @IBOutlet weak var invoiceTotal : UILabel!
    @IBOutlet weak var discount : UITextField!
    
    var selectedId : Int32 = 0
    var customerArray : [String] = []
    var customerAddressArray : [String] = []
    
    let dbInstance = KCDBUtility()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        self.billedTo.text = self.customerArray[row]
        self.billedToAddress.text = self.customerAddressArray[row]
        self.billedTo.endEditing(true)
    
    }
    
    @IBAction func printButtonTapped(_ sender: Any) {
        
    }
        
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let util = KCUtility()
        
        var hasData = false
        var id : String = ""
        
        if (self.selectedId == 0) {
            let querySql = "select id from invoice_table where invoice_number='" + (invoiceNumber.text)! + "'"
            
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
            var updateSql = "update invoice_table set billed_to='" + (billedTo.text)! + "', "
            updateSql += "billed_to_address='" + (billedToAddress.text)! + "', "
            updateSql += "invoice_number='" + (invoiceNumber.text)! + "', "
            updateSql += "date_of_issue='" + (dateOfIssue.text)! + "', "
            updateSql += "invoice_total=" + (invoiceTotal.text)! + ", "
            updateSql += "discount=" + (discount.text)! + ", "
            updateSql += "create_time='" + util.getTodayStr() + "' "
            updateSql += "where id=" + id
            
            let result = dbInstance.executeSQL(sql: updateSql)
            print("update invoice info=\(result)")
            
            
        } else {
            var insertSql = "insert into invoice_table (billed_to, billed_to_address, "
            insertSql += "invoice_number, date_of_issue, invoice_total, discount, create_time) values ('"
            insertSql += (billedTo.text)! + "', '" + (billedToAddress.text)! + "', '"
            insertSql += (invoiceNumber.text)! + "', '" + (dateOfIssue.text)! + "', "
            insertSql += (invoiceTotal.text)! + ", " + (discount.text)! + ", '"
            insertSql += util.getTodayStr() + "')"
            
            print("total=" + (invoiceTotal.text)!)
            print("insertSql=" + insertSql)
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert invoice info=\(result)")
            
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        
        let util = KCUtility()
        
        let queryCustomerSql = "select id, customer_name, address from customer_table"
        print("query customer_table")
        
        if let queryCustomerResult = dbInstance.querySQL(sql: queryCustomerSql) {
            
            for row in queryCustomerResult {
                if let num = row["id"] {
                    print("id=\(num)")
                    
                    customerArray.append((row["customer_name"] as? String)!)
                    customerAddressArray.append((row["address"] as? String)!)
                    
                    
                }
                
            }
        }
        
        let billedToPickerView = UIPickerView()

        billedToPickerView.delegate = self
        billedToPickerView.dataSource = self
        billedTo.inputView = billedToPickerView
        
        if (self.selectedId > 0) {
            
            let querySql = "select id, billed_to, billed_to_address, invoice_number, date_of_issue, invoice_total, discount from invoice_table"
            print("query invoice_table")
            
            if let queryResult = dbInstance.querySQL(sql: querySql) {
                
                for row in queryResult {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        billedTo.text = (row["billed_to"] as? String)!
                        billedToAddress.text = (row["billed_to_address"] as? String)!
                        invoiceNumber.text = (row["invoice_number"] as? String)!
                        dateOfIssue.text = (row["date_of_issue"] as? String)!
                        invoiceTotal.text = String(describing: (row["invoice_total"] as? Double)! - (row["discount"] as? Double)!)
                        
                    }
                    
                }
            }
            print("query end")
        } else {
            
            dateOfIssue.text = util.getDateOfIssue()
            
            let querySql = "select id+1 as numOfOrder from invoice_table where date_of_issue = '" + dateOfIssue.text! + "'"
            print("query invoice_table")
            
            if let queryResult = dbInstance.querySQL(sql: querySql) {
                for row in queryResult {
                    if let numOfOrder = row["numOfOrder"] {
                        print("numOfOrder=\(numOfOrder)")
                        invoiceNumber.text = util.getInvoiceNumber(num: String(describing: numOfOrder))
                    }
                }
            }
            
        }
    }
}
