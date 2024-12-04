//
//  UserCell.swift
//  AppShared
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import Domain
import Kingfisher
import DesignSystem

final class UserCell: BaseCollectionViewCell {
    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.white500
        view.layer.cornerRadius = 12
        view.layer.shadowColor = Design.Colors.white500?.withAlphaComponent(0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1
        return view
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = Design.Colors.gray400
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Typography.semibold14
        label.textColor = Design.Colors.black500
        return label
    }()

    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Typography.regular14
        label.textColor = .systemBlue
        return label
    }()

    // MARK: - Configuration

    override func configurationLayout() {
        applyViewConfiguration()
    }

    func configure(with item: UserCellItem) {
        nameLabel.text = item.login
        urlLabel.text = item.htmlUrl

        if let url = URL(string: item.avatarUrl) {
            avatarImageView.kf.setImage(with: url)
        }
    }

    func configure(with user: User) {
        configure(with: UserCellItem(from: user))
    }
}

// MARK: - View Configuration

extension UserCell: BaseViewConfiguration {
    func buildHierachy() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubviews([
            avatarImageView,
            nameLabel,
            urlLabel,
        ])
    }

    func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(50)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView)
            $0.left.equalTo(avatarImageView.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-16)
        }

        urlLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.left.equalTo(nameLabel)
            $0.right.equalTo(nameLabel)
        }
    }

    func setupStyles() {}
}
