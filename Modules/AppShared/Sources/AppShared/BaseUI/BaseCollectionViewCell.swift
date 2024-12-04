//
//  BaseCollectionViewCell.swift
//  AppShared
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

open class BaseCollectionViewCell: UICollectionViewCell, Reusable {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configurationLayout()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open func configurationLayout() {}
}
