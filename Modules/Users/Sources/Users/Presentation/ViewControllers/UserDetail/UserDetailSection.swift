//
//  UserDetailSection.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import Domain

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
            let cell: UserHeaderCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: item)
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
