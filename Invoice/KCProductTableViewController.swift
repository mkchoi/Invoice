//
//  KCProductTableViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 11/23/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCProductTableViewController : UITableViewController {
    
    @IBOutlet weak var editBarButton : UIBarButtonItem!
    
    var selectedId : Int32 = 0
    var productInfoView : KCProductInfoViewController?
    
    var productArray: [String] = []
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
            
            let deleteSql = "delete from product_table where id=\(idArray[indexPath.row])"
            let result = dbInstance.executeSQL(sql: deleteSql)
            print("delete product info=\(result)")
            
            if (result) {
                productArray.remove(at: indexPath.row)
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
        return productArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productTableCell", for: indexPath)
        
        cell.textLabel?.text = productArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedId = idArray[indexPath.row]
        self.performSegue(withIdentifier: "modifyProductSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "modifyProductSegue") {
            if (self.selectedId > 0) {
                productInfoView = segue.destination as? KCProductInfoViewController
                productInfoView?.selectedId = self.selectedId
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        productArray.removeAll()
        
        let querySql = "select id, item_code, item_desc from product_table"
        print("query product_table")
        
        if let queryResult = dbInstance.querySQL(sql: querySql) {
            
            for row in queryResult {
                if let code = row["item_code"] {
                    print("item_code=\(code)")
                    idArray.append(row["id"] as! Int32)
                    productArray.append(row["item_desc"] as! String)
                }
            }
        }
        
        self.tableView.reloadData()
        
        print("query end")
    }
}
