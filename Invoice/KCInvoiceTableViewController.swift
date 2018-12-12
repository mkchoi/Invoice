//
//  KCInvoiceTableViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/23/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCInvoiceTableViewController : UITableViewController {
    
    @IBOutlet weak var editBarButton : UIBarButtonItem!

    var selectedId : Int32 = 0
    var invoiceView : KCInvoiceViewController?

    var invoiceArray: [String] = []
    var idArray: [Int32] = []
    
    let dbInstance = KCDBUtility()
    
    @IBAction func showEditing(_ sender: Any)
    {
        if(self.tableView.isEditing == true)
        {
            self.tableView.isEditing = false
            self.editBarButton?.title = "編輯"
        }
        else
        {
            self.tableView.isEditing = true
            self.editBarButton?.title = "完成"
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let deleteSql = "delete from invoice_table where id=\(idArray[indexPath.row])"
            let result = dbInstance.executeSQL(sql: deleteSql)
            print("delete product info=\(result)")
            
            if (result) {
                invoiceArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (self.tableView.isEditing) {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }

    override func tableView(_ tableView : UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoiceArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invoiceTableCell", for: indexPath)
        
        cell.textLabel?.text = invoiceArray[indexPath.row]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedId = idArray[indexPath.row]
        self.performSegue(withIdentifier: "modifyInvoiceSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "modifyInvoiceSegue") {
            if (self.selectedId > 0) {
                invoiceView = segue.destination as? KCInvoiceViewController
                invoiceView?.selectedId = self.selectedId
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        invoiceArray.removeAll()
        
        let querySql = "select id, billed_to, invoice_number, date_of_issue, invoice_total from invoice_table"
        print("query invoice_table")
        
        if let queryResult = dbInstance.querySQL(sql: querySql) {
            
            for row in queryResult {
                if let num = row["invoice_number"] {
                    print("invoice_number=\(num)")
                    idArray.append(row["id"] as! Int32)
                    let invoiceNumber = row["invoice_number"] as! String
                    let dateOfIssue = row["date_of_issue"] as! String
                    let billedTo = row["billed_to"] as! String
                    let invoiceTotal = row["invoice_total"] as! Double
                    let desc = "\(dateOfIssue) \(invoiceNumber) \(billedTo) $\(invoiceTotal)"
                    invoiceArray.append(desc)
                }
            }
        }
        
        self.tableView.reloadData()
        
        print("query end")
    }
}
