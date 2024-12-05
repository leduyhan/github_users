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
    case loading
    case idle
}

// MARK: - Protocols

protocol UserListViewModelInputs {
    func viewDidLoad()
    func loadMore()
    func didSelectUser(at index: Int)
}

protocol UserListViewModelOutputs {
    var state: Observable<ViewState> { get }
    var selectedUser: Observable<UserCellItem> { get }
    var error: Observable<Error> { get }
}

protocol UserListViewModelType {
    var inputs: UserListViewModelInputs { get }
    var outputs: UserListViewModelOutputs { get }
}

// MARK: - View State

struct ViewState: Equatable {
    var items: [UserCellItem]
    var isLoading: Bool
    
    static let initial = ViewState(items: [], isLoading: false)
}

// MARK: - Implementation

final class UserListViewModel {
    private struct Constants {
        static let perPage = 20
    }
    
    // MARK: - Dependencies
    
    private let useCase: FetchUsersUseCase
    private let disposeBag = DisposeBag()
    
    // MARK: - State
    
    private let stateRelay = BehaviorRelay(value: ViewState.initial)
    private let selectedUserRelay = PublishRelay<UserCellItem>()
    private let errorRelay = PublishRelay<Error>()
    
    private var currentPage = 0
    private var isLoading: Bool { stateRelay.value.isLoading }
    
    // MARK: - Initialization
    
    init(useCase: FetchUsersUseCase = DefaultFetchUsersUseCase(repository: DefaultUserRepository())) {
        self.useCase = useCase
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
        loadUsers(isInitialLoad: true)
    }
    
    func loadMore() {
        loadUsers(isInitialLoad: false)
    }
    
    func didSelectUser(at index: Int) {
        guard index >= 0, index < stateRelay.value.items.count else { return }
        selectedUserRelay.accept(stateRelay.value.items[index])
    }
}

// MARK: - UserListViewModelOutputs

extension UserListViewModel: UserListViewModelOutputs {
    var state: Observable<ViewState> { stateRelay.asObservable() }
    var selectedUser: Observable<UserCellItem> { selectedUserRelay.asObservable() }
    var error: Observable<Error> { errorRelay.asObservable() }
}

// MARK: - Private Methods

private extension UserListViewModel {
    func loadUsers(isInitialLoad: Bool) {
        guard !isLoading else { return }
        
        updateState { state in
            state.isLoading = true
        }
        
        let since = isInitialLoad ? 0 : (currentPage * Constants.perPage)
        
        useCase.execute(since: since, perPage: Constants.perPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] users in
                    self?.handleSuccess(users: users, isInitialLoad: isInitialLoad)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func handleSuccess(users: [User], isInitialLoad: Bool) {
        let newItems = users.map(UserCellItem.init)
        
        updateState { state in
            if isInitialLoad {
                state.items = newItems
                currentPage = 1  // Set to 1 after initial load
            } else {
                state.items.append(contentsOf: newItems)
                currentPage += 1
            }
            state.isLoading = false
        }
    }
    
    func handleError(_ error: Error) {
        updateState { state in
            state.isLoading = false
        }
        errorRelay.accept(error)
    }
    
    func updateState(update: (inout ViewState) -> Void) {
        var newState = stateRelay.value
        update(&newState)
        stateRelay.accept(newState)
    }
}
