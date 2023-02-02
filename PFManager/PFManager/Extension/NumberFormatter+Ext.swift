//
//  NumberFormatter+Ext.swift
//  PFManager
//
//  Created by junemp on 2022/11/29.
//

import Foundation

extension NumberFormatter {
    static func currency(from value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let formattedValue = formatter.string(from: NSNumber(value: value)) ?? ""
        
        return "$" + formattedValue
    }
}
