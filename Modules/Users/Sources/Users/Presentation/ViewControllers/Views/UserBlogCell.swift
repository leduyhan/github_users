//
//  UserBlogCell.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import DesignSystem

final class UserBlogCell: BaseCollectionViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Typography.semibold16
        label.text = "Blog"
        return label
    }()
    
    private lazy var blogLabel: UILabel = {
        let label = UILabel()
        label.font = Design.Typography.regular14
        label.textColor = Design.Colors.gray
        return label
    }()
    
    override func configurationLayout() {
        applyViewConfiguration()
    }
    
    func configure(with item: UserBlogCellItem) {
        blogLabel.text = item.url
    }
}

extension UserBlogCell: BaseViewConfiguration {
    func buildHierachy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(blogLabel)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        blogLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
}
