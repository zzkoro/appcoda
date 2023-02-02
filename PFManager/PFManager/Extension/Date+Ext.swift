//
//  Date+Ext.swift
//  PFManager
//
//  Created by junemp on 2022/11/27.
//

import Foundation

extension Date {
    static var today: Date {
        return Date()
    }
    
    func string(with format: String = "dd MMM yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
