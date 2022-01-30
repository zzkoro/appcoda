//
//  UINavigationBar+Ext.swift
//  Fooders
//
//  Created by junemp on 2022/01/21.
//

import Foundation

import UIKit

extension UINavigationBar {
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 10)
    }
}
