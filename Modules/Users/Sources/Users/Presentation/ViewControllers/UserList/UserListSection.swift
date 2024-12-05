//
//  UserListSection.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import Domain
import AppShared
import DesignSystem

enum UserListSection: Int, CaseIterable {
    case users
    case loader
}

enum UserListSectionItem: Hashable {
    case user(UserCellItem)
    case loader
    
    func cellProvider(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        switch self {
        case .user(let user):
            let cell: UserCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: UserCellConfiguration.user(user))
            return cell
            
        case .loader:
            let cell: LoaderCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure()
            return cell
        }
    }
}

extension UserListSection {
    var layoutSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(PADDING120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: PADDING16,
            bottom: PADDING16,
            trailing: 16
        )
        section.interGroupSpacing = PADDING8
        
        return section
    }
}

struct UserCellItem: Hashable {
    let uuid = UUID()
    let login: String
    let avatarUrl: String
    let htmlUrl: String

    init(from user: User) {
        self.login = user.login
        self.avatarUrl = user.avatarUrl
        self.htmlUrl = user.htmlUrl
    }
}
