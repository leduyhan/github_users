//
//  UserDetailSection.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import Domain
import DesignSystem

enum UserDetailSection: Int, CaseIterable {
    case header
    case stats
    case blog
}

enum UserDetailSectionItem: Hashable {
    case header(UserHeaderCellItem)
    case stats(UserStatsCellItem)
    case blog(UserBlogCellItem)
    
    func cellProvider(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        switch self {
        case .header(let item):
            let cell: UserCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: UserCellConfiguration.header(item))
            return cell
            
        case .stats(let item):
            let cell: UserStatsCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: item)
            return cell
            
        case .blog(let item):
            let cell: UserBlogCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: item)
            return cell
        }
    }
}

extension UserDetailSection {
    var layoutSection: NSCollectionLayoutSection {
        switch self {
        case .header:
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(PADDING120)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(PADDING100)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: PADDING16,
                leading: PADDING16,
                bottom: PADDING16,
                trailing: PADDING16
            )
            return section
            
        case .stats:
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(PADDING80)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: item.layoutSize,
                subitems: [item]
            )
            return NSCollectionLayoutSection(group: group)

        case .blog:
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(PADDING70)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: item.layoutSize,
                subitems: [item]
            )
            return NSCollectionLayoutSection(group: group)
        }
    }
}

struct UserHeaderCellItem: Hashable {
    let avatarUrl: String
    let login: String
    let location: String?
    
    init(user: UserDetail) {
        self.avatarUrl = user.avatarUrl
        self.login = user.login
        self.location = user.location
    }
}

struct UserStatsCellItem: Hashable {
    let followers: Int
    let following: Int
    
    init(user: UserDetail) {
        self.followers = user.followers
        self.following = user.following
    }
}

struct UserBlogCellItem: Hashable {
    let url: String
    
    init(url: String) {
        self.url = url
    }
}
