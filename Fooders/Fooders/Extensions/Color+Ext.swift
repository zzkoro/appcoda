//
//  Color+Ext.swift
//  Fooders
//
//  Created by junemp on 2021/10/25.
//

import SwiftUI

extension Color {
    var uiColor: UIColor? {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        } else {
            let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            var hexNumber: UInt64 = 0
            var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
            let result = scanner.scanHexInt64(&hexNumber)
            if result {
                r = CGFloat((hexNumber & 0xff000000) >> 24)
                g = CGFloat((hexNumber & 0x00ff0000) >> 16)
                b = CGFloat((hexNumber & 0x0000ff00) >> 8)
                a = CGFloat(hexNumber & 0x000000ff) / 255
                return UIColor(red: r, green: g, blue: b, alpha: a)
            } else {
                return nil
            }
        }
    }
}
