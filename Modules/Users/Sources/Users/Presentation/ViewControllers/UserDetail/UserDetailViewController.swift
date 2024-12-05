//
//  UserDetailViewController.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import Domain
import RxSwift

typealias UserDetailCellProvider = (UICollectionView, IndexPath, UserDetailSectionItem) -> UICollectionViewCell?
typealias UserDetailDataSource = UICollectionViewDiffableDataSource<UserDetailSection, UserDetailSectionItem>
typealias UserDetailSnapshot = NSDiffableDataSourceSnapshot<UserDetailSection, UserDetailSectionItem>

final class UserDetailViewController: UIViewController {
    private let viewModel: UserDetailViewModelType
    private let disposeBag = DisposeBag()
    private var dataSource: UserDetailDataSource?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.register(cellType: UserCell.self)
        collectionView.register(cellType: UserStatsCell.self)
        collectionView.register(cellType: UserBlogCell.self)
        collectionView.backgroundColor = .systemGray6
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    init(viewModel: UserDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyViewConfiguration()
        setupCollectionView()
        setupBindings()
        viewModel.inputs.viewDidLoad()
    }
}

// MARK: - CollectionView Setup

private extension UserDetailViewController {
    func setupCollectionView() {
        collectionView.setCollectionViewLayout(
            createCollectionViewLayout(),
            animated: false
        )
        dataSource = createDataSource(collectionView: collectionView)
    }

    func createCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] section, _ in
            guard let section = UserDetailSection(rawValue: section) else { return nil }
            return self?.layoutSection(for: section)
        }
    }

    func layoutSection(for section: UserDetailSection) -> NSCollectionLayoutSection {
        switch section {
        case .header:
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(120)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(100)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            return section
            
        case .stats:
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(80)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: item.layoutSize,
                subitems: [item]
            )
            return NSCollectionLayoutSection(group: group)

        case .blog:
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(70)
            ))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: item.layoutSize,
                subitems: [item]
            )
            return NSCollectionLayoutSection(group: group)
        }
    }

    func createDataSource(collectionView: UICollectionView) -> UserDetailDataSource {
        UserDetailDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                item.cellProvider(collectionView: collectionView, indexPath: indexPath)
            }
        )
    }

    func updateSnapshot(with user: UserDetail) {
        var snapshot = UserDetailSnapshot()
        let sections: [UserDetailSection] = [.header, .stats, .blog]
        snapshot.appendSections(sections)

        snapshot.appendItems([.header(.init(user: user))], toSection: .header)
        snapshot.appendItems([.stats(.init(user: user))], toSection: .stats)
        snapshot.appendItems([.blog(.init(url: user.htmlUrl))], toSection: .blog)

        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Bindings

private extension UserDetailViewController {
    func setupBindings() {
        viewModel.outputs.user
            .subscribe(
                with: self,
                onNext: { owner, user in
                    owner.updateSnapshot(with: user)
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - View Configuration

extension UserDetailViewController: BaseViewConfiguration {
    func buildHierachy() {
        view.addSubview(collectionView)
    }

    func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupStyles() {
        title = "User Details"
        view.backgroundColor = .systemGray6
    }
}
