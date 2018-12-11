//
//  KCUtility.swift
//  Invoice
//
//  Created by Kevin Choi on 10/18/18.
//  Copyright © 2018 Kevin Choi. All rights reserved.
//

import Foundation

class KCUtility {
    
    func getCurrentDay() -> (Double) {
        let currentSec = Date().timeIntervalSince1970;
        return currentSec / (60 * 60 * 24);
    }
    
    func getTodayStr() -> (String) {
        let currDate = Date();
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: currDate);
        
        return dateString;
    }
        
    func getEscapedString(originalString : String) -> (String) {
        let escaped = originalString.replacingOccurrences(of: "'", with: "''");
        return escaped;
    }
    
    func getDateOfIssue() -> (String) {
        let currDate = Date();
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatterGet.string(from: currDate);
        
        return dateString;
    }
    
    func getInvoiceNumber(num : String) -> (String) {
        let currDate = Date();
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyMMdd"
        let dateString = dateFormatterGet.string(from: currDate);
        
        if (num.count < 4) {
            let remain = 4-num.count
            if (remain == 3) {
                return dateString + "000" + num
            } else if (remain == 2) {
                return dateString + "00" + num
            } else if (remain == 1) {
                return dateString + "0" + num
            }
        }
        return dateString + num;
    }

}
