//
//  UserDetailViewModel.swift
//  Users
//
//  Created by Hận Lê on 12/3/24.
//

import Domain
import RxRelay
import RxSwift
import Data

// MARK: - Protocols

protocol UserDetailViewModelInputs {
    func viewDidLoad()
    func refresh()
}

protocol UserDetailViewModelOutputs {
    var user: Observable<UserDetail> { get }
    var error: Observable<Error> { get }
}

protocol UserDetailViewModelType {
    var inputs: UserDetailViewModelInputs { get }
    var outputs: UserDetailViewModelOutputs { get }
}

// MARK: - Implementation

final class UserDetailViewModel {
    // MARK: - Dependencies
    
    private let useCase: FetchUserDetailUseCase
    private let disposeBag = DisposeBag()
    private let username: String
    
    // MARK: - State
    
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let refreshRelay = PublishRelay<Void>()
    private let userRelay = BehaviorRelay<UserDetail?>(value: nil)
    private let errorRelay = PublishRelay<Error>()

    init(
        username: String,
        useCase: FetchUserDetailUseCase = DefaultFetchUserDetailUseCase(repository: DefaultUserRepository())
    ) {
        self.username = username
        self.useCase = useCase
        setupBindings()
    }
}

// MARK: - UserDetailViewModelType

extension UserDetailViewModel: UserDetailViewModelType {
    var inputs: UserDetailViewModelInputs { self }
    var outputs: UserDetailViewModelOutputs { self }
}

// MARK: - UserDetailViewModelInputs

extension UserDetailViewModel: UserDetailViewModelInputs {
    func viewDidLoad() {
        viewDidLoadRelay.accept(())
    }
    
    func refresh() {
        refreshRelay.accept(())
    }
}

// MARK: - UserDetailViewModelOutputs

extension UserDetailViewModel: UserDetailViewModelOutputs {
    var user: Observable<UserDetail> { userRelay.compactMap { $0 } }
    var error: Observable<Error> { errorRelay.asObservable() }
}

// MARK: - Private Methods

private extension UserDetailViewModel {
    func setupBindings() {
        let fetchTrigger = Observable.merge(
            viewDidLoadRelay.asObservable(),
            refreshRelay.asObservable()
        )

        fetchTrigger
            .flatMapLatest { [useCase, username] in
                useCase.execute(username: username)
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, event in
                switch event {
                case .next(let user):
                    owner.userRelay.accept(user)
                case .error(let error):
                    owner.errorRelay.accept(error)
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
