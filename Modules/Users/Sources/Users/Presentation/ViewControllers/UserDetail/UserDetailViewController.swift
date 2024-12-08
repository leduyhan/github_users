//
//  UserDetailViewController.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import Domain
import RxSwift
import DesignSystem

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
        collectionView.backgroundColor = Design.Colors.white500
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
         let control = UIRefreshControl()
         control.tintColor = Design.Colors.gray
         return control
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
        UICollectionViewCompositionalLayout { section, _ in
            guard let section = UserDetailSection(rawValue: section) else { return nil }
            return section.layoutSection
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
                    owner.refreshControl.endRefreshing()
                }
            )
            .disposed(by: disposeBag)
        bindRefreshControl()
        bindError()
    }
    
    func bindRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.inputs.refresh()
            })
            .disposed(by: disposeBag)
    }
    
    func bindError() {
        viewModel.outputs.error
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, error in
                owner.showError(error.localizedDescription)
                owner.refreshControl.endRefreshing()
            })
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
        title = L10n.textUserDetailTitle
        view.backgroundColor = .systemGray6
    }
}

