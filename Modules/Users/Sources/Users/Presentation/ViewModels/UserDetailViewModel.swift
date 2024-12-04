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
}

protocol UserDetailViewModelOutputs {
    var user: Observable<UserDetail> { get }
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
    
    // MARK: - Streams
    
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let userRelay = BehaviorRelay<UserDetail?>(value: nil)
    
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
}

// MARK: - UserDetailViewModelOutputs

extension UserDetailViewModel: UserDetailViewModelOutputs {
    var user: Observable<UserDetail> { userRelay.compactMap { $0 } }
}

// MARK: - Private Methods

private extension UserDetailViewModel {
    func setupBindings() {
        viewDidLoadRelay
            .flatMapLatest { [useCase, username] in
                useCase.execute(username: username).asObservable()
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                with: self,
                onNext: { owner, user in
                    owner.userRelay.accept(user)
                }
            )
            .disposed(by: disposeBag)
    }
}
