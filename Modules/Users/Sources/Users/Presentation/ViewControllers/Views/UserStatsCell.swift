//
//  UserStatsCell.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared

final class UserStatsCell: BaseCollectionViewCell {
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
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
        
        statsStackView.addArrangedSubview(followerView)
        statsStackView.addArrangedSubview(followingView)
    }
    
    private func createStatsView(icon: String, count: Int, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
        
        let countLabel = UILabel()
        countLabel.text = "\(count)+"
        countLabel.font = .systemFont(ofSize: 16, weight: .medium)
        countLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .gray
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
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16))
        }
    }
}
