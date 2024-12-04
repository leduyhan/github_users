//
//  UserListSection.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import Domain
import AppShared

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
            cell.configure(with: user)
            return cell
            
        case .loader:
            let cell: LoaderCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure()
            return cell
        }
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(88)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
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
