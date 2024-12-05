//
//  UserViewController.swift
//  Pods
//
//  Created by Hận Lê on 12/3/24.
//

import RxCocoa
import RxSwift
import SnapKit
import AppShared
import DesignSystem

typealias UserListCellProvider = (UICollectionView, IndexPath, UserListSectionItem) -> UICollectionViewCell?
typealias UserListDataSource = UICollectionViewDiffableDataSource<UserListSection, UserListSectionItem>
typealias UserListSnapshot = NSDiffableDataSourceSnapshot<UserListSection, UserListSectionItem>

final class UserListViewController: UIViewController {
    private let viewModel: UserListViewModelType
    private let disposeBag = DisposeBag()
    private var dataSource: UserListDataSource?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.register(cellType: UserCell.self)
        collectionView.register(cellType: LoaderCell.self)
        collectionView.backgroundColor = Design.Colors.white500
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private var onShowDetail: ((String) -> Void)?

    init(viewModel: UserListViewModelType, onShowDetail: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.onShowDetail = onShowDetail
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
private extension UserListViewController {
    func setupCollectionView() {
        collectionView.setCollectionViewLayout(
            createCollectionViewLayout(),
            animated: false
        )
        dataSource = createDataSource(collectionView: collectionView)
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(PADDING120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: PADDING16,
            bottom: PADDING16,
            trailing: 16
        )
        section.interGroupSpacing = PADDING8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func createDataSource(collectionView: UICollectionView) -> UserListDataSource {
        let cellProvider: UserListCellProvider = { collectionView, indexPath, item in
            return item.cellProvider(collectionView: collectionView, indexPath: indexPath)
        }
        
        return UserListDataSource(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
    }
    
    func updateSnapshot(with items: [UserCellItem], isLoading: Bool) {
        var snapshot = UserListSnapshot()
        snapshot.appendSections([.users])
        snapshot.appendItems(items.map { .user($0) }, toSection: .users)
        
        if isLoading {
            snapshot.appendSections([.loader])
            snapshot.appendItems([.loader], toSection: .loader)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Bindings
private extension UserListViewController {
    func setupBindings() {
        bindViewState()
        bindSelection()
        bindInfiniteScrolling()
        bindError()
    }
    
    func bindError() {
        viewModel.outputs.error
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, error in
                owner.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewState() {
        viewModel.outputs.state
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                with: self,
                onNext: { owner, state in
                    owner.updateSnapshot(
                        with: state.items,
                        isLoading: state.isLoading
                    )
                }
            )
            .disposed(by: disposeBag)
    }
    
    func bindSelection() {
        collectionView.rx.itemSelected
            .map { $0.row }
            .subscribe(
                with: self,
                onNext: { owner, index in
                    owner.viewModel.inputs.didSelectUser(at: index)
                }
            )
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectedUser
            .withUnretained(self)
            .subscribe(onNext: { owner, user in
                owner.onShowDetail?(user.login)
            })
            .disposed(by: disposeBag)
    }
    
    func bindInfiniteScrolling() {
        collectionView.rx.didScroll
            .withLatestFrom(viewModel.outputs.state) { ($0, $1) }
            .withUnretained(self)
            .map { owner, args -> Bool in
                let (_, state) = args
                guard !state.isLoading else { return false }
                
                let offsetY = owner.collectionView.contentOffset.y
                let contentHeight = owner.collectionView.contentSize.height
                let frameHeight = owner.collectionView.frame.height
                
                return offsetY > contentHeight - frameHeight - PADDING20
            }
            .distinctUntilChanged()
            .filter { $0 }
            .withUnretained(self)
            .bind(onNext: { owner, _ in
                owner.viewModel.inputs.loadMore()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - View Configuration
extension UserListViewController: BaseViewConfiguration {
    func buildHierachy() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupStyles() {
        title = L10n.textUsersTitle
    }
}
