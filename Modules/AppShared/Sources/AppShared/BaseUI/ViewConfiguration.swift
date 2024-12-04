//
//  ViewConfiguration.swift
//  AppShared
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public protocol ConfigurableCell {
    associatedtype DataType
    func configure(with item: DataType)
}

public protocol BaseViewConfiguration {
    func buildHierachy()
    func setupConstraints()
    func setupStyles()
}

extension BaseViewConfiguration {
    public func applyViewConfiguration() {
        buildHierachy()
        setupConstraints()
        setupStyles()
    }

    public func setupStyles() {}
}
