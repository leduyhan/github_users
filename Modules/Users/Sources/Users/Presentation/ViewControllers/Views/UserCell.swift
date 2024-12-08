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

// MARK: - Configuration Protocol
protocol UserCellConfigurable {
    var avatarUrl: String { get }
    var name: String { get }
    var url: String? { get }
    var location: String? { get }
}

// MARK: - Configuration Implementations
enum UserCellConfiguration {
    case user(UserCellItem)
    case header(UserHeaderCellItem)
}

extension UserCellConfiguration: UserCellConfigurable {
    var avatarUrl: String {
        switch self {
        case .user(let item):
            return item.avatarUrl
        case .header(let item):
            return item.avatarUrl
        }
    }
    
    var name: String {
        switch self {
        case .user(let item):
            return item.login
        case .header(let item):
            return item.login
        }
    }
    
    var url: String? {
        switch self {
        case .user(let item):
            return item.htmlUrl
        case .header:
            return nil
        }
    }
    
    var location: String? {
        switch self {
        case .user:
            return nil
        case .header(let item):
            return item.location
        }
    }
}

final class UserCell: BaseCollectionViewCell {
    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.white500
        view.layer.cornerRadius = PADDING16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: PADDING1)
        view.layer.shadowRadius = PADDING4
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var avatarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Design.Colors.gray400
        view.layer.cornerRadius = PADDING16
        view.clipsToBounds = true
        return view
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Design.Colors.gray400
        imageView.layer.cornerRadius = PADDING88/2
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
        stackView.spacing = PADDING8
        return stackView
    }()

    private lazy var locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = PADDING4
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

    func configure(with configuration: UserCellConfigurable) {
        nameLabel.text = configuration.name
        urlLabel.text = configuration.url
        
        if let url = URL(string: configuration.avatarUrl) {
            avatarImageView.kf.setImage(with: url)
        }
        
        if let location = configuration.location {
            locationLabel.text = location
            locationStackView.isHidden = false
        } else {
            locationStackView.isHidden = true
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
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(
                    top: PADDING4,
                    left: 0,
                    bottom: PADDING4,
                    right: 0
                )
            )
        }

        avatarContainerView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(PADDING8)
            $0.width.equalTo(avatarContainerView.snp.height)
        }

        avatarImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(PADDING4)
        }

        infoStackView.snp.makeConstraints {
            $0.left.equalTo(avatarContainerView.snp.right).offset(PADDING16)
            $0.top.equalTo(avatarContainerView).offset(PADDING2)
            $0.right.equalToSuperview().offset(-PADDING16)
        }

        locationIcon.snp.makeConstraints {
            $0.size.equalTo(PADDING16)
        }

        separatorLine.snp.makeConstraints {
            $0.height.equalTo(PADDING1)
        }
    }

    func setupStyles() {}
}
