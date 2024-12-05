//
//  UserCell.swift
//  AppShared
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import DesignSystem
import Domain
import Kingfisher

enum UserCellType {
    case userCell(UserCellItem)
    case userHeaderCell(UserHeaderCellItem)
}

final class UserCell: BaseCollectionViewCell {
    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.white500
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.05
        return view
    }()

    private lazy var avatarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.gray400
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Design.Colors.gray400
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Typography.semibold16
        label.textColor = Design.Colors.black500
        return label
    }()

    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.gray400
        return view
    }()

    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Typography.regular14
        label.textColor = Design.Colors.blue
        label.alpha = 0.8
        return label
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private lazy var locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()

    private lazy var locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "location")
        imageView.tintColor = Design.Colors.gray
        return imageView
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Typography.regular14
        label.textColor = Design.Colors.gray
        return label
    }()

    // MARK: - Configuration

    override func configurationLayout() {
        applyViewConfiguration()
    }

    func configure(with type: UserCellType) {
        switch type {
        case .userCell(let item):
            nameLabel.text = item.login
            urlLabel.text = item.htmlUrl
            locationStackView.isHidden = true
            
            if let url = URL(string: item.avatarUrl) {
                avatarImageView.kf.setImage(with: url)
            }
            
        case .userHeaderCell(let item):
            nameLabel.text = item.login
            urlLabel.text = ""
            
            if let url = URL(string: item.avatarUrl) {
                avatarImageView.kf.setImage(with: url)
            }
            
            if let location = item.location {
                locationLabel.text = location
                locationStackView.isHidden = false
            } else {
                locationStackView.isHidden = true
            }
        }
        
        DispatchQueue.main.async {
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height / 2
        }
    }
}

// MARK: - View Configuration

extension UserCell: BaseViewConfiguration {
    func buildHierachy() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubviews([
            avatarContainerView,
            infoStackView,
        ])

        [
            locationIcon,
            locationLabel,
        ].forEach {
            locationStackView.addArrangedSubview($0)
        }

        [
            nameLabel,
            separatorLine,
            locationStackView,
            urlLabel
        ].forEach {
            infoStackView.addArrangedSubview($0)
        }
        avatarContainerView.addSubview(avatarImageView)
    }

    func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        }

        avatarContainerView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(avatarContainerView.snp.height)
        }

        avatarImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        infoStackView.snp.makeConstraints {
            $0.left.equalTo(avatarContainerView.snp.right).offset(16)
            $0.top.equalTo(avatarContainerView).offset(2)
            $0.right.equalToSuperview().offset(-16)
        }

        locationIcon.snp.makeConstraints {
            $0.size.equalTo(16)
        }

        separatorLine.snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }

    func setupStyles() {}
}
