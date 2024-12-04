//
//  UserViewModel.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import Data
import Domain
import RxRelay
import RxSwift

// MARK: - Types

enum LoadingState {
    case initial
    case pagination
    case none
}

// MARK: - Protocols

protocol UserListViewModelInputs {
    func viewDidLoad()
    func loadMore()
    func refresh()
    func didSelectUser(at index: Int)
}

protocol UserListViewModelOutputs {
    var items: Observable<[UserCellItem]> { get }
    var loadingState: Observable<LoadingState> { get }
    var error: Observable<Error> { get }
    var selectedUser: Observable<UserCellItem> { get }
}

protocol UserListViewModelType {
    var inputs: UserListViewModelInputs { get }
    var outputs: UserListViewModelOutputs { get }
}

// MARK: - Implementation

final class UserListViewModel {
    private struct Constants {
        static let perPage = 20
    }
    
    private struct State {
        var currentPage = 0
        var items: [UserCellItem] = []
        var loadingState: LoadingState = .none
    }
    
    // MARK: - Dependencies
    
    private let useCase: FetchUsersUseCase
    private let disposeBag = DisposeBag()
    
    // MARK: - State
    
    private var state = State()
    
    // MARK: - Streams
    
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let loadMoreRelay = PublishRelay<Void>()
    private let refreshRelay = PublishRelay<Void>()
    private let selectedIndexRelay = PublishRelay<Int>()
    
    private let itemsRelay = BehaviorRelay<[UserCellItem]>(value: [])
    private let loadingStateRelay = BehaviorRelay<LoadingState>(value: .none)
    private let errorRelay = PublishRelay<Error>()
    private let selectedUserRelay = PublishRelay<UserCellItem>()
    
    // MARK: - Initialization
    
    init(useCase: FetchUsersUseCase = DefaultFetchUsersUseCase(repository: UserRepositoryFactory.makeRepository())) {
        self.useCase = useCase
        setupBindings()
    }
}

// MARK: - UserListViewModelType

extension UserListViewModel: UserListViewModelType {
    var inputs: UserListViewModelInputs { self }
    var outputs: UserListViewModelOutputs { self }
}

// MARK: - UserListViewModelInputs

extension UserListViewModel: UserListViewModelInputs {
    func viewDidLoad() {
        viewDidLoadRelay.accept(())
    }
    
    func loadMore() {
        loadMoreRelay.accept(())
    }
    
    func refresh() {
        refreshRelay.accept(())
    }
    
    func didSelectUser(at index: Int) {
        selectedIndexRelay.accept(index)
    }
}

// MARK: - UserListViewModelOutputs

extension UserListViewModel: UserListViewModelOutputs {
    var items: Observable<[UserCellItem]> { itemsRelay.asObservable() }
    var loadingState: Observable<LoadingState> { loadingStateRelay.asObservable() }
    var error: Observable<Error> { errorRelay.asObservable() }
    var selectedUser: Observable<UserCellItem> { selectedUserRelay.asObservable() }
}

// MARK: - Private Methods

private extension UserListViewModel {
    func setupBindings() {
        setupDataLoadingBindings()
        setupUserSelectionBindings()
    }
    
    func setupDataLoadingBindings() {
        let loadingTrigger = createLoadingTrigger().observe(on: MainScheduler.asyncInstance)
        let isRefreshStream = createRefreshStream().observe(on: MainScheduler.asyncInstance)

        loadingTrigger
            .withLatestFrom(loadingStateRelay) { trigger, current in
                current == .none ? trigger : current
            }
            .filter { $0 != .none }
            .withUnretained(self)
            .map { owner, state in (state, owner.state.currentPage) }
            .withLatestFrom(isRefreshStream) { args, isRefresh in
                (args.0, args.1, isRefresh)
            }
            .withUnretained(self)
            .flatMapLatest { (owner, arg1) -> Observable<[UserCellItem]> in
                let (state, page, isRefresh) = arg1
                return owner.handleDataFetch(state: state, page: page, isRefresh: isRefresh)
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                with: self,
                onNext: { owner, items in
                    owner.handleNewItems(items)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func setupUserSelectionBindings() {
        selectedIndexRelay
            .withLatestFrom(itemsRelay) { index, items -> UserCellItem? in
                guard index >= 0, index < items.count else { return nil }
                return items[index]
            }
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: selectedUserRelay)
            .disposed(by: disposeBag)
    }
    
    func createLoadingTrigger() -> Observable<LoadingState> {
        Observable.merge([
            viewDidLoadRelay.map { LoadingState.initial },
            loadMoreRelay.map { LoadingState.pagination },
            refreshRelay.map { LoadingState.initial }
        ])
    }
    
    func createRefreshStream() -> Observable<Bool> {
        Observable.merge([
            refreshRelay.map { true },
            viewDidLoadRelay.map { false },
            loadMoreRelay.map { false }
        ])
    }
    
    func handleDataFetch(state: LoadingState, page: Int, isRefresh: Bool) -> Observable<[UserCellItem]> {
        loadingStateRelay.accept(state)
        
        if isRefresh {
            self.state.currentPage = 0
            itemsRelay.accept([])
        }
        
        return useCase.execute(since: page * Constants.perPage,
                             perPage: Constants.perPage,
                             forceRefresh: isRefresh)
            .asObservable()
            .map { $0.map(UserCellItem.init) }
            .do(
                onNext: { [weak self] _ in
                    self?.loadingStateRelay.accept(.none)
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                    self?.loadingStateRelay.accept(.none)
                }
            )
            .catch { _ in .just([]) }
    }
    
    func handleNewItems(_ newItems: [UserCellItem]) {
        let currentItems = itemsRelay.value
        itemsRelay.accept(currentItems + newItems)
        state.currentPage += 1
    }
}
