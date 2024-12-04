//
//  LoaderCell.swift
//  AppShared
//
//  Created by Hận Lê on 12/4/24.
//

import SnapKit

public final class LoaderCell: BaseCollectionViewCell {
    private lazy var spinner = UIActivityIndicatorView(style: .medium)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(spinner)
        spinner.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    public func configure() {
        spinner.startAnimating()
    }
}
