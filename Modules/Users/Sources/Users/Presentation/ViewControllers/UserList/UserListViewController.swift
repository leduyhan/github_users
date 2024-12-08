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
    
    private lazy var refreshControl: UIRefreshControl = {
         let control = UIRefreshControl()
         control.tintColor = Design.Colors.gray
         return control
     }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.register(cellType: UserCell.self)
        collectionView.register(cellType: LoaderCell.self)
        collectionView.backgroundColor = Design.Colors.white500
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
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
        UICollectionViewCompositionalLayout { section, _ in
            guard let section = UserListSection(rawValue: section) else { return nil }
            return section.layoutSection
        }
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
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Bindings
private extension UserListViewController {
    func setupBindings() {
        bindViewState()
        bindSelection()
        bindInfiniteScrolling()
        bindError()
        bindRefreshControl()
    }
    
    func bindRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.inputs.refresh()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { owner, isLoading in
                if !isLoading {
                    owner.refreshControl.endRefreshing()
                }
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
        collectionView.rx.willDisplayCell
            .withLatestFrom(viewModel.outputs.state) { ($0, $1) }
            .withUnretained(self)
            .filter { owner, args in
                let ((_, indexPath), state) = args
                guard !state.isLoading else { return false }
                return owner.collectionView.isLastVisibleCell(at: indexPath)
            }
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
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

extension UICollectionView {
    func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
        guard let lastIndexPath = lastIndexPath else { return false }
        return indexPath == lastIndexPath
    }
    
    private var lastIndexPath: IndexPath? {
        let section = numberOfSections - 1
        guard section >= 0 else { return nil }
        
        let item = numberOfItems(inSection: section) - 1
        guard item >= 0 else { return nil }
        
        return IndexPath(item: item, section: section)
    }
}
