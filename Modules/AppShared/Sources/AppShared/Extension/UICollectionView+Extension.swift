//
//  UICollectionView+Extension.swift
//  AppShared
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation
import UIKit

public protocol Reusable {
    static var identifier: String { get }
}

extension Reusable {
    public static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    public func register<T: UICollectionViewCell>(cellType: T.Type) where T: Reusable {
        self.register(cellType.self, forCellWithReuseIdentifier: cellType.identifier)
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(
        for indexPath: IndexPath,
        cellType: T.Type = T.self
    ) -> T where T: Reusable {
        let bareCell = self.dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath)
        guard let cell = bareCell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.identifier) matching type \(cellType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }

    public func register<T: UICollectionReusableView>(
        supplementaryViewType: T.Type,
        ofKind elementKind: String
    ) where T: Reusable {
        self.register(
            supplementaryViewType.self,
            forSupplementaryViewOfKind: elementKind,
            withReuseIdentifier: supplementaryViewType.identifier
        )
    }

    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        ofKind elementKind: String,
        for indexPath: IndexPath,
        viewType: T.Type = T.self
    ) -> T where T: Reusable {
        let view = self.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: viewType.identifier,
            for: indexPath
        )
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.identifier) "
                    + "matching type \(viewType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the supplementary view beforehand"
            )
        }
        return typedView
    }
}
