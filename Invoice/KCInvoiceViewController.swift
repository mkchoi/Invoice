//
//  KCInvoiceViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/29/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCInvoiceViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var invoiceNumber : UITextField!
    @IBOutlet weak var dateOfIssue : UITextField!
    @IBOutlet weak var billedTo : UITextField!
    @IBOutlet weak var billedToAddress : UITextView!
    @IBOutlet weak var invoiceTotal : UILabel!
    @IBOutlet weak var discount : UITextField!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var deleteButton : UIButton!
    @IBOutlet weak var selBilledTo : UIButton!
    @IBOutlet weak var paymentMethod: UITextField!
    
    var selectedId : Int32 = 0
    var customerArray : [String] = []
    var customerAddressArray : [String] = []
    
    var itemArray: [String] = []
    var qtyArray: [Double] = []
    var amountArray: [Double] = []
    var idArray: [Int32] = []
    
    var invoiceItemView : KCInvoiceItemViewController?
    var previewView : KCPreviewViewController?
    
    let dbInstance = KCDBUtility()
    let billedToPickerView = UIPickerView()
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let deleteSql = "delete from invoice_item_table where id=\(idArray[indexPath.row])"
            let result = dbInstance.executeSQL(sql: deleteSql)
            print("delete item info=\(result)")
            
            if (result) {
                reloadTableView()
                //itemArray.remove(at: indexPath.row)
                //self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (self.tableView.isEditing) {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView : UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemTableCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        if let label1 = cell.viewWithTag(1) as? UILabel {
            label1.text = String(describing: qtyArray[indexPath.row])
        }
        
        if let label2 = cell.viewWithTag(2) as? UILabel {
            label2.text = "$ " + String(describing: amountArray[indexPath.row])
        }
        
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedId = idArray[indexPath.row]
        self.performSegue(withIdentifier: "modifyProductSegue", sender: self)
    }
    */
    
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
    
    @IBAction func deleteItemButtonTapped(_ sender: Any) {
        if(self.tableView.isEditing == true)
        {
            self.tableView.isEditing = false
            self.deleteButton?.setTitle("刪除貨品", for: UIControlState.normal)
        }
        else
        {
            self.tableView.isEditing = true
            self.deleteButton?.setTitle("完成刪除", for: UIControlState.normal)
        }
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
            updateSql += "payment_method='" + (paymentMethod.text)! + "', "
            updateSql += "invoice_total=" + (invoiceTotal.text)! + ", "
            updateSql += "discount=" + (discount.text)! + ", "
            updateSql += "create_time='" + util.getTodayStr() + "' "
            updateSql += "where id=" + id
            
            let result = dbInstance.executeSQL(sql: updateSql)
            print("update invoice info=\(result)")
            
            
        } else {
            var insertSql = "insert into invoice_table (billed_to, billed_to_address, "
            insertSql += "invoice_number, date_of_issue, payment_method, invoice_total, discount, create_time) values ('"
            insertSql += (billedTo.text)! + "', '" + (billedToAddress.text)! + "', '"
            insertSql += (invoiceNumber.text)! + "', '" + (dateOfIssue.text)! + "', '"
            insertSql += (paymentMethod.text)! + "', "
            insertSql += (invoiceTotal.text)! + ", " + (discount.text)! + ", '"
            insertSql += util.getTodayStr() + "')"
            
            print("total=" + (invoiceTotal.text)!)
            print("insertSql=" + insertSql)
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert invoice info=\(result)")
            
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func selectBilledTo(_ sender: Any) {
    
        if (selBilledTo.titleLabel!.text == "選擇") {
            if (customerArray.count > 0) {
                billedTo.inputView = billedToPickerView
            }
            billedTo.becomeFirstResponder()
            selBilledTo!.setTitle("輸入", for: UIControlState.normal)
        } else {
            billedTo.inputView = nil
            billedTo.reloadInputViews()
            billedTo.becomeFirstResponder()
            selBilledTo!.setTitle("選擇", for: UIControlState.normal)
        }
        
       
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        /*var updateSql = "update invoice_table set "
        updateSql += "billed_to='" + (billedTo.text)! + "', "
        updateSql += "billed_to_address='" + (billedToAddress.text)! + "', "
        updateSql += "invoice_total=" + (invoiceTotal.text)! + ", "
        updateSql += "discount=" + (discount.text)! + " "
        updateSql += "where id=\(self.selectedId)"
        
        let result = dbInstance.executeSQL(sql: updateSql)
        print("update invoice info=\(result)")*/
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc private func invoiceItemReload() {
        print("invoiceItemReload")
        
        reloadTableView()
    }
    
    func reloadTableView() {
        itemArray.removeAll()
        qtyArray.removeAll()
        amountArray.removeAll()
        idArray.removeAll()
        
        let querySql = "select id, item_desc, qty, amount from invoice_item_table where invoice_id=\(self.selectedId)"
        print("query invoice_item_table")
        
        var amount : Double = 0.0
        
        if let queryResult = dbInstance.querySQL(sql: querySql) {
            
            for row in queryResult {
                if let name = row["item_desc"] {
                    print("item_desc=\(name)")
                    idArray.append(row["id"] as! Int32)
                    itemArray.append(row["item_desc"] as! String)
                    qtyArray.append(row["qty"] as! Double)
                    amountArray.append(row["amount"] as! Double)
                    
                    amount += row["amount"] as! Double
                }
            }
        }
        
        self.tableView.reloadData()
        invoiceTotal.text = String(describing: amount)
        
        print("query end")
    
        var updateSql = "update invoice_table set "
        updateSql += "invoice_total=" + (invoiceTotal.text)! + " "
        updateSql += "where id=\(self.selectedId)"
        
        let result = dbInstance.executeSQL(sql: updateSql)
        print("update invoice info=\(result)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let util = KCUtility()
        
        reloadTableView()
        
        if (self.selectedId > 0) {
            
            let querySql = "select id, billed_to, billed_to_address, invoice_number, date_of_issue, payment_method, invoice_total, discount from invoice_table where id=\(self.selectedId)"
            print("query invoice_table")
            
            if let queryResult = dbInstance.querySQL(sql: querySql) {
                
                for row in queryResult {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        billedTo.text = (row["billed_to"] as? String)!
                        billedToAddress.text = (row["billed_to_address"] as? String)!
                        invoiceNumber.text = (row["invoice_number"] as? String)!
                        dateOfIssue.text = (row["date_of_issue"] as? String)!
                        paymentMethod.text = (row["payment_method"] as? String)!
                        invoiceTotal.text = String(describing: (row["invoice_total"] as? Double)!)
                        discount.text = String(describing: (row["discount"] as? Double)!)
                        
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
            } else {
                invoiceNumber.text = util.getInvoiceNumber(num: "1")
            }
            
            var insertSql = "insert into invoice_table ("
            insertSql += "invoice_number, date_of_issue, invoice_total, discount, create_time) values ('"
            insertSql += (invoiceNumber.text)! + "', '" + (dateOfIssue.text)! + "', 0, 0, '"
            insertSql += util.getTodayStr() + "')"
            
            print("insertSql=" + insertSql)
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert invoice info=\(result)")
            
            let querySql2 = "select id from invoice_table where invoice_number=" + (invoiceNumber.text)!
            print("query2 invoice_table")
            
            if let queryResult2 = dbInstance.querySQL(sql: querySql2) {
                
                for row in queryResult2 {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        self.selectedId = (num as? Int32)!
                    }
                    
                }
            }
            
        }
        
        if (paymentMethod.text == "") {
            paymentMethod.text = "月結"
        }
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(invoiceItemReload), name: NSNotification.Name("invoiceItemReload"), object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        customerArray.removeAll()
        customerAddressArray.removeAll()
        
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
        
        billedToPickerView.delegate = self
        billedToPickerView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide , object: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "invoiceItemSegue") {
            if (self.selectedId > 0) {
                invoiceItemView = segue.destination as? KCInvoiceItemViewController
                invoiceItemView?.selectedId = self.selectedId
            }
        } else if (segue.identifier == "previewSegue") {
            if (self.selectedId > 0) {
                print("previewSegue")
                print("billedTo=\(self.billedTo.text)!")
                var updateSql = "update invoice_table set "
                updateSql += "billed_to='" + (self.billedTo.text)! + "', "
                updateSql += "billed_to_address='" + (self.billedToAddress.text)! + "', "
                updateSql += "payment_method='" + (self.paymentMethod.text)! + "', "
                updateSql += "invoice_total=" + (self.invoiceTotal.text)! + ", "
                updateSql += "discount=" + (self.discount.text)! + " "
                updateSql += "where id=\(self.selectedId)"
                
                let result = dbInstance.executeSQL(sql: updateSql)
                print("update invoice info=\(result)")
                
                let backItem = UIBarButtonItem()
                backItem.title = "返回"
                navigationItem.backBarButtonItem = backItem
                
                previewView = segue.destination as? KCPreviewViewController
                
                let invoiceNo = self.invoiceNumber.text!
                let invoiceDate = self.dateOfIssue.text!
                let payMethod = self.paymentMethod.text!
                
                var companyInfo = ""
                
                let queryComSql = "select id, company_name, address, tel, email from company_table"
                print("query company_table")
                
                if let queryComResult = dbInstance.querySQL(sql: queryComSql) {
                    
                    for row in queryComResult {
                        if let num = row["id"] {
                            print("id=\(num)")
                            
                            companyInfo = (row["company_name"] as? String)!
                            companyInfo += "<br>\((row["address"] as? String)!)"
                            companyInfo += "<br>\((row["tel"] as? String)!)"
                            companyInfo += "<br>\((row["email"] as? String)!)"
                            
                        }
                        
                    }
                }
                
                
                var recipientInfo = self.billedTo.text! + " (" + self.billedToAddress.text! + ")"
                if (self.billedToAddress.text == "") {
                    recipientInfo = self.billedTo.text!
                }
                let invoiceDiscount = self.discount.text!
                
                let d = Double(self.discount.text!) ?? 0
                let t = Double(self.invoiceTotal.text!) ?? 0
        
                let totalAmount = String(describing: (t - d))
                
                let querySql = "select id, item_desc, item_unit, unit_price, qty, amount from invoice_item_table where invoice_id=\(self.selectedId)"
                print("query invoice_item_table")
                
                
                var items = [[String: String]]()
                
                if let queryResult = dbInstance.querySQL(sql: querySql) {
                    
                    for row in queryResult {
                        if let num = row["id"] {
                            print("id=\(num)")
                            
                            let itemDesc = (row["item_desc"] as? String)!
                            let itemUnit = (row["item_unit"] as? String)!
                            var unitPrice = ""
                            if let dUnitPrice = row["unit_price"] as? Double {
                                unitPrice = String(describing: dUnitPrice)
                            }
                            let qty = String(describing: (row["qty"] as? Double)!)
                            let amount = String(describing: (row["amount"] as? Double)!)
                            
                            items.append(["item": itemDesc, "itemUnit": itemUnit, "unitPrice": unitPrice, "qty": qty, "price": amount])
                            
                        }
                        
                    }
                }
                
                let queryCurSql = "select id, currency_unit from currency_table"
                print("query currency_table")
                
                var currency = "HKD"
                
                if let queryCurResult = dbInstance.querySQL(sql: queryCurSql) {
                    
                    for row in queryCurResult {
                        if let num = row["id"] {
                            print("id=\(num)")
                            
                            currency = (row["currency_unit"] as? String)!
                            
                        }
                        
                    }
                }
                
                
                let invoice = ["invoiceNumber": invoiceNo, "invoiceDate": invoiceDate, "senderInfo": companyInfo, "recipientInfo": recipientInfo, "discount": invoiceDiscount, "totalAmount": totalAmount, "currency": currency, "paymentMethod": payMethod, "items": items] as [String : AnyObject]
                
                previewView?.invoiceInfo = invoice
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard will hide!")
        
        if (billedTo.isFirstResponder) {
            let queryCustomerSql = "select id, customer_name, address from customer_table where customer_name='" + billedTo.text! + "'"
            print("query customer_table")
            
            if let queryCustomerResult = dbInstance.querySQL(sql: queryCustomerSql) {
                
                for row in queryCustomerResult {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        billedToAddress.text = (row["address"] as? String)!
                        
                        break
                    }
                    
                }
            }
        }
    }
}
