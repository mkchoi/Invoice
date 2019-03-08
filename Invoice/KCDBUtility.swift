//
//  KCDBUtility.swift
//  Invoice
//
//  Created by Kevin Choi on 10/13/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation
import SQLite3

class KCDBUtility {
    
    typealias CCharPointer = UnsafeMutablePointer<CChar>;
    
    var instance : KCDBUtility? = nil;
    var dbName : String = "invoice";
    var dbContent : String = "Initial DB";
    var dbVersion = 10;
    var db:OpaquePointer? = nil;

    var createDbVerTable = "CREATE TABLE IF NOT EXISTS dbver_table "
        + "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "content TEXT, "
        + "dbver INTEGER, "
        + "alter_num INTEGER DEFAULT 0, "
        + "create_time DATETIME)";
    
    var createInvoiceTable = "CREATE TABLE IF NOT EXISTS invoice_table "
        + "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "billed_to TEXT, "
        + "billed_to_address TEXT, "
        + "invoice_number TEXT, "
        + "date_of_issue DATETIME, "
        + "payment_method TEXT, "
        + "invoice_total REAL, "
        + "discount REAL, "
        + "create_time DATETIME)";
    
    var createInvoiceItemTable = "CREATE TABLE IF NOT EXISTS invoice_item_table "
        + "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "invoice_id INTEGER, "
        + "item_code TEXT, "
        + "item_desc TEXT, "
        + "item_unit TEXT, "
        + "unit_price REAL, "
        + "qty REAL, "
        + "amount REAL, "
        + "create_time DATETIME)";
    
    var createProductTable = "CREATE TABLE IF NOT EXISTS product_table "
        + "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "item_code TEXT, "
        + "item_desc TEXT, "
        + "item_unit TEXT, "
        + "unit_price REAL, "
        + "create_time DATETIME)";
    
    var createCustomerTable = "CREATE TABLE IF NOT EXISTS customer_table "
        + "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "customer_name TEXT, "
        + "address TEXT, "
        + "create_time DATETIME)";
    
    var createCompanyTable = "CREATE TABLE IF NOT EXISTS company_table "
        + "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "company_name TEXT, "
        + "address TEXT, "
        + "tel TEXT, "
        + "email TEXT, "
        + "create_time DATETIME)";
    
    var createCurrencyTable = "CREATE TABLE IF NOT EXISTS currency_table "
        + "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
        + "currency_unit TEXT, "
        + "create_time DATETIME)";

    
    var dropDbVerTable = "DROP TABLE dbver_table";
    var dropInvoiceTable = "DROP TABLE invoice_table";
    var dropInvoiceItemTable = "DROP TABLE invoice_item_table";
    var dropProductTable = "DROP TABLE product_table";
    var dropCustomerTable = "DROP TABLE customer_table";
    var dropCompanyTable = "DROP TABLE company_table";
    var dropCurrencyTable = "DROP TABLE currency_table";
    
    var deleteInvoiceTable = "DELETE FROM invoice_table";
    var deleteInvoiceItemTable = "DELETE FROM invoice_item_table";
    var deleteProductTable = "DELETE FROM product_table";
    var deleteCustomerTable = "DELETE FROM customer_table";
    var deleteCompanyTable = "DELETE FROM company_table";
    var deleteCurrencyTable = "DELETE FROM currency_table";
    
    init() {
        openDB();
        createDB();
        upgradeDB();
    }
    
    deinit {
        closeDB();
    }
    
    func openDB() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let databaseFilePath = documentsPath + "/" + dbName;
        
        print("openDB=" + databaseFilePath);
        
        if (sqlite3_open(databaseFilePath, &db) == SQLITE_OK) {
            print("open sqlite db ok");
        }
    }
    
    func createDB() {
        objc_sync_enter(self);
        
        var errorMsg : CCharPointer?;
        if (sqlite3_exec(db, createDbVerTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, createInvoiceTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, createInvoiceItemTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, createProductTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, createCustomerTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, createCompanyTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, createCurrencyTable, nil, nil, &errorMsg) == SQLITE_OK) {
            
            print("create tables ok");
            
            let query = "select count(*) from dbver_table";
            var statement : OpaquePointer?;
            let errCode = sqlite3_prepare_v2(db, query, -1, &statement, nil);
            
            if (errCode == SQLITE_OK) {
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    let count = sqlite3_column_int(statement, 0);
                    
                    if (count == 0) {
                        let utility = KCUtility();
                        var sql = "insert into dbver_table (content, dbver, create_time) values ('" + dbContent + "', '"
                        sql += "\(dbVersion)" + "', '" + utility.getTodayStr() + "')";
                        
                        if (sqlite3_exec(db, sql, nil, nil, &errorMsg) == SQLITE_OK) {
                            print("insert dbver ok");
                        } else {
                            let error = String(cString: errorMsg!);
                            print("cannot insert dbver - " + error);
                            
                            self.closeDB();
                        }
                        
                    }
                }
            }
            
            sqlite3_finalize(statement);
            
        } else {
            print("failed to createDB");
            if let error = errorMsg {
                print("error: %s", error);
            }
        }
        
        objc_sync_exit(self);
        
        print("createDB end");
    }
    
    public func closeDB() {
        sqlite3_close(db);
        instance = nil;
    }
    
    func upgradeDB() {
        
        var dbVer : Int32 = 0;
        
        objc_sync_enter(self);
        
        let query = "select dbver from dbver_table";
        var statement : OpaquePointer?;
        let errCode = sqlite3_prepare_v2(db, query, -1, &statement, nil);
        
        if (errCode == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                dbVer = sqlite3_column_int(statement, 0);
                
            }
        }
        
        sqlite3_finalize(statement);
        
        objc_sync_exit(self);
        
        print("dbVer=\(dbVer)");
        
        if (dbVer < dbVersion) {
            dropDB();
            createDB();
        }
        
    }
    
    func dropDB() {
        
        objc_sync_enter(self);
        
        var errorMsg : CCharPointer?;
        
        if (sqlite3_exec(db, dropDbVerTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, dropInvoiceTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, dropInvoiceItemTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, dropProductTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, dropCustomerTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, dropCompanyTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, dropCurrencyTable, nil, nil, &errorMsg) == SQLITE_OK) {
            
            print("drop tables ok");
        }
        
        objc_sync_exit(self);
        
    }
    
    func resetDB() {
        
        objc_sync_enter(self);
        
        var errorMsg : CCharPointer?;
        
        if (sqlite3_exec(db, deleteInvoiceTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, deleteInvoiceItemTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, deleteProductTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, deleteCustomerTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, deleteCompanyTable, nil, nil, &errorMsg) == SQLITE_OK
            && sqlite3_exec(db, deleteCurrencyTable, nil, nil, &errorMsg) == SQLITE_OK) {
            
            print("delete tables ok");
        }
        
        objc_sync_exit(self);
        
    }
    
    func initLaoShanHang() {
        
        objc_sync_enter(self);
        
        var errorMsg : CCharPointer?;
        
        let pathToTxtFile = Bundle.main.path(forResource: "laoshanhang", ofType: "txt")
        
        //reading
        do {
            let sqlFile = try String(contentsOfFile: pathToTxtFile!, encoding: .utf8)
            
            let allSqlStr = sqlFile.components(separatedBy: .newlines)
            
            for sqlStr in allSqlStr {
                if (sqlite3_exec(db, sqlStr, nil, nil, &errorMsg) == SQLITE_OK) {
                    print("insert laoshanhang ok " + sqlStr);
                }
            }
        }
        catch {
            print("exception")
        }
        
       
        
        objc_sync_exit(self);
        
    }
    
    public func executeSQL(sql : String) -> Bool {
        
        objc_sync_enter(self);
        
        var err: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(db,sql.cString(using: String.Encoding.utf8)!,nil,nil,&err) != SQLITE_OK {
            if let error = String(validatingUTF8:sqlite3_errmsg(db)) {
                print("execute failed to execute  Error: \(error)")
            }
            
            objc_sync_exit(self);
            return false
        }
        
        objc_sync_exit(self);
        return true;
        
    }
    
    public func querySQL(sql : String) -> [[String:Any]]? {
        objc_sync_enter(self);
        
        var arr:[[String:Any]] = [];
        var  statement: OpaquePointer? = nil;
        
        if sqlite3_prepare_v2(db,sql.cString(using: String.Encoding.utf8)!,-1,&statement,nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let columns = sqlite3_column_count(statement);
                var row:[String:Any] = Dictionary();
                for i in 0..<columns {
                    let type = sqlite3_column_type(statement, i);
                    let chars = UnsafePointer<CChar>(sqlite3_column_name(statement, i));
                    let name =  String.init(cString: chars!, encoding: String.Encoding.utf8);
                    
                    var value: Any;
                    switch type {
                    case SQLITE_INTEGER:
                        value = sqlite3_column_int(statement, i);
                    case SQLITE_FLOAT:
                        value = sqlite3_column_double(statement, i);
                    case SQLITE_TEXT:
                        let chars = UnsafePointer<CUnsignedChar>(sqlite3_column_text(statement, i));
                        value = String.init(cString: chars!);
                        
                    case SQLITE_BLOB:
                        let data = sqlite3_column_blob(statement, i);
                        let size = sqlite3_column_bytes(statement, i);
                        value = NSData(bytes:data, length:Int(size));
                    default:
                        value = "";
                        ()
                    }
                    
                    row.updateValue(value, forKey: "\(name!)");
                }
                arr.append(row);
                //print("added row")
            }
        }
        sqlite3_finalize(statement)
        
        objc_sync_exit(self);
        
        if arr.count == 0 {
            print("nothing found")
            return nil;
        } else {
            print("count=\(arr.count)")
            return arr;
        }
        
    }

    
}
