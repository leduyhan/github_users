//
//  UserHeaderCell.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared

final class UserHeaderCell: BaseCollectionViewCell {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 30
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "location")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    override func configurationLayout() {
        applyViewConfiguration()
    }
    
    func configure(with item: UserHeaderCellItem) {
        nameLabel.text = item.login
        locationLabel.text = item.location
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.kf.setImage(with: url)
        }
    }
}

extension UserHeaderCell: BaseViewConfiguration {
    func buildHierachy() {
        contentView.addSubview(containerView)
        containerView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(locationIcon)
        containerView.addSubview(locationLabel)
    }
    
    func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16))
        }
        
        avatarContainer.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(60)
        }
        
        avatarImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarContainer.snp.top).offset(8)
            $0.left.equalTo(avatarContainer.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        
        locationIcon.snp.makeConstraints {
            $0.left.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.size.equalTo(16)
        }
        
        locationLabel.snp.makeConstraints {
            $0.centerY.equalTo(locationIcon)
            $0.left.equalTo(locationIcon.snp.right).offset(4)
        }
    }
}
