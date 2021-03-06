//
//  KCInvoiceItemViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 12/12/2018.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCInvoiceItemViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var itemCode : UITextField!
    @IBOutlet weak var itemDesc : UITextField!
    @IBOutlet weak var itemUnit : UITextField!
    @IBOutlet weak var unitPrice : UITextField!
    @IBOutlet weak var qty : UITextField!
    @IBOutlet weak var amount : UITextField!
    @IBOutlet weak var selItemCode: UIButton!
    @IBOutlet weak var selItemDesc: UIButton!
    
    var selectedId : Int32 = 0
    var productArray : [String] = []
    var productDescArray : [String] = []
    var productUnitArray : [String] = []
    var productUnitPriceArray : [Double] = []
    
    let dbInstance = KCDBUtility()
    let itemCodePickerView = UIPickerView()
    let itemDescPickerView = UIPickerView()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return productArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1) {
            return productArray[row]
        } else {
            return productDescArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1) {
            self.itemCode.text = self.productArray[row]
            self.itemDesc.text = self.productDescArray[row]
            self.itemUnit.text = self.productUnitArray[row]
            self.unitPrice.text = String(self.productUnitPriceArray[row])
            self.itemCode.endEditing(true)
        } else {
            self.itemCode.text = self.productArray[row]
            self.itemDesc.text = self.productDescArray[row]
            self.itemUnit.text = self.productUnitArray[row]
            self.unitPrice.text = String(self.productUnitPriceArray[row])
            self.itemDesc.endEditing(true)
        }
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let util = KCUtility()
        
        if let itemCodeText = self.itemCode.text, itemCodeText.isEmpty
        {
            // create the alert
            let alert = UIAlertController(title: "錯誤", message: "請輸入貨品代號", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if let itemDescText = self.itemDesc.text, itemDescText.isEmpty
        {
            // create the alert
            let alert = UIAlertController(title: "錯誤", message: "請輸入貨品名稱", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if let itemQtyText = self.qty.text, itemQtyText.isEmpty
        {
            // create the alert
            let alert = UIAlertController(title: "錯誤", message: "請輸入數量", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if let itemUnitPriceText = self.unitPrice.text, !itemUnitPriceText.isEmpty
        {
            let unitPriceDouble = Double(self.unitPrice.text!) ?? 0
            let qtyDouble = Double(self.qty.text!.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            let amountDouble = unitPriceDouble * qtyDouble
            
            self.amount.text = String(describing: amountDouble)
        }
        
        if let itemAmountText = self.amount.text, itemAmountText.isEmpty
        {
            // create the alert
            let alert = UIAlertController(title: "錯誤", message: "請輸入總金額", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        print("selectedId=\(self.selectedId)")
        
        if (self.selectedId > 0) {
            
            var insertSql = "insert into invoice_item_table (invoice_id, item_code, item_desc, item_unit, unit_price, qty, amount, create_time) values "
            insertSql += "(\(self.selectedId), '" + (itemCode.text)! + "', '"
            insertSql += (itemDesc.text)! + "', '" + (itemUnit.text)! + "', '" + (unitPrice.text)! + "', '"
            insertSql += (qty.text)! + "', '" + (amount.text)! + "', '"
            insertSql += util.getTodayStr() + "')"
            
            let result = dbInstance.executeSQL(sql: insertSql)
            print("insert invoice item=\(result)")
        } 
        
        NotificationCenter.default.post(name: NSNotification.Name("invoiceItemReload"), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func selectItemCode(_ sender: Any) {
        
        if (selItemCode.titleLabel!.text == "選擇") {
            if (productArray.count > 0) {
                itemCode.inputView = itemCodePickerView
            }
            itemCode.becomeFirstResponder()
            selItemCode!.setTitle("輸入", for: UIControlState.normal)
        } else {
            itemCode.inputView = nil
            itemCode.reloadInputViews()
            itemCode.becomeFirstResponder()
            selItemCode!.setTitle("選擇", for: UIControlState.normal)
        }
        
    }
    
    @IBAction func selectItemDesc(_ sender: Any) {
        
        if (selItemDesc.titleLabel!.text == "選擇") {
            if (productDescArray.count > 0) {
                itemDesc.inputView = itemDescPickerView
            }
            itemDesc.becomeFirstResponder()
            selItemDesc!.setTitle("輸入", for: UIControlState.normal)
        } else {
            itemDesc.inputView = nil
            itemDesc.reloadInputViews()
            itemDesc.becomeFirstResponder()
            selItemDesc!.setTitle("選擇", for: UIControlState.normal)
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    override func viewDidLoad() {
        
        productArray.removeAll()
        productDescArray.removeAll()
        productUnitArray.removeAll()
        productUnitPriceArray.removeAll()
        
        let queryProductSql = "select id, item_code, item_desc, item_unit, unit_price from product_table"
        print("query product_table")
        
        if let queryProductResult = dbInstance.querySQL(sql: queryProductSql) {
            
            for row in queryProductResult {
                if let num = row["id"] {
                    print("id=\(num)")
                    
                    productArray.append((row["item_code"] as? String)!)
                    productDescArray.append((row["item_desc"] as? String)!)
                    productUnitArray.append((row["item_unit"] as? String)!)
                    productUnitPriceArray.append((row["unit_price"] as? Double)!)
                    
                }
                
            }
        }
        
        itemCodePickerView.tag = 1
        itemCodePickerView.delegate = self
        itemCodePickerView.dataSource = self
        
        
        itemDescPickerView.tag = 2
        itemDescPickerView.delegate = self
        itemDescPickerView.dataSource = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide , object: nil)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard will hide!")
        
        if (itemCode.isFirstResponder) {
            let queryProductSql = "select id, item_code, item_desc, item_unit, unit_price from product_table where item_code='" + itemCode.text! + "'"
            print("query product_table")
            
            if let queryProductResult = dbInstance.querySQL(sql: queryProductSql) {
                
                for row in queryProductResult {
                    if let num = row["id"] {
                        print("id=\(num)")
                        
                        itemDesc.text = (row["item_desc"] as? String)!
                        itemUnit.text = (row["item_unit"] as? String)!
                        unitPrice.text = String(describing: (row["unit_price"] as? Double)!)
                        
                        break
                    }
                    
                }
            }
        }
    }
    
}
