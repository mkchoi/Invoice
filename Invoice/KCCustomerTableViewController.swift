//
//  KCCustomerTableViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/23/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCCustomerTableViewController : UITableViewController {

    @IBOutlet weak var editBarButton : UIBarButtonItem!
    
    var selectedId : Int32 = 0
    var customerInfoView : KCCustomerInfoViewController?
    
    var customerArray: [String] = []
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
            
            let deleteSql = "delete from customer_table where id=\(idArray[indexPath.row])"
            let result = dbInstance.executeSQL(sql: deleteSql)
            print("delete customer info=\(result)")
            
            if (result) {
                customerArray.remove(at: indexPath.row)
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
        return customerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerTableCell", for: indexPath)
        
        cell.textLabel?.text = customerArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedId = idArray[indexPath.row]
        self.performSegue(withIdentifier: "modifyCustomerSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "modifyCustomerSegue") {
            if (self.selectedId > 0) {
                customerInfoView = segue.destination as? KCCustomerInfoViewController
                customerInfoView?.selectedId = self.selectedId
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        customerArray.removeAll()
        idArray.removeAll()
        
        let querySql = "select id, customer_name from customer_table"
        print("query customer_table")
         
        if let queryResult = dbInstance.querySQL(sql: querySql) {
         
            for row in queryResult {
                if let name = row["customer_name"] {
                    print("customer_name=\(name)")
                    idArray.append(row["id"] as! Int32)
                    customerArray.append(row["customer_name"] as! String)
                }
            }
        }
        
        self.tableView.reloadData()
        
        print("query end")
    }
    
    
    
}
