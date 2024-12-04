//
//  UIView+Extension.swift
//  AppShared
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public extension UIView {
    @discardableResult
    func addSubviews(_ views: UIView...) -> UIView {
        for view in views {
            addSubview(view)
        }
        return self
    }
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
