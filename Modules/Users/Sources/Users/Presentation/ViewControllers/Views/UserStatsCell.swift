//
//  UserStatsCell.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import DesignSystem

final class UserStatsCell: BaseCollectionViewCell {
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    override func configurationLayout() {
        applyViewConfiguration()
    }
    
    func configure(with item: UserStatsCellItem) {
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let followerView = createStatsView(
            icon: "person.2",
            count: item.followers,
            title: "Follower"
        )
        let followingView = createStatsView(
            icon: "person.badge.plus",
            count: item.following,
            title: "Following"
        )
        [
            followerView,
            followingView,
        ].forEach { statsStackView.addArrangedSubview($0) }
    }
    
    private func createStatsView(icon: String, count: Int, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = Design.Colors.black500
        iconView.contentMode = .scaleAspectFit
        
        let countLabel = UILabel()
        countLabel.text = "\(count)+"
        countLabel.font = Design.Typography.semibold16
        countLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Design.Typography.regular14
        titleLabel.textColor = Design.Colors.gray
        titleLabel.textAlignment = .center
        
        container.addSubview(iconView)
        container.addSubview(countLabel)
        container.addSubview(titleLabel)
        
        iconView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
            $0.size.equalTo(24)
        }
        
        countLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(iconView.snp.bottom).offset(4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(countLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        return container
    }
}

extension UserStatsCell: BaseViewConfiguration {
    func buildHierachy() {
        contentView.addSubview(statsStackView)
    }
    
    func setupConstraints() {
        statsStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 8, right: 40))
        }
    }
}
