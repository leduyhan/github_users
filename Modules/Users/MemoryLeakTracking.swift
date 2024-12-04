//
//  MemoryLeakTracking.swift
//  Users-Unit-UsersTests
//
//  Created by Hận Lê on 12/4/24.
//

import XCTest
import RxSwift
@testable import Domain
@testable import Data
@testable import Users

final class UserComponentsMemoryLeakTests: XCTestCase {
    func test_usersViewModel_doesNotCreateMemoryLeak() {
        let sut = UserListViewModel()
        checkForMemoryLeak(sut)
    }
    
    func test_usersViewController_doesNotCreateMemoryLeak() {
        let viewModel = UserListViewModel()
        let sut = UserListViewController(viewModel: viewModel) { _ in }
        checkForMemoryLeak(sut)
        
        sut.loadViewIfNeeded()
    }
    
    func test_repository_doesNotCreateMemoryLeak() {
        let sut = DefaultUserRepository()
        checkForMemoryLeak(sut)
    }
    
    func test_detailViewModel_doesNotCreateMemoryLeak() {
        let sut = UserDetailViewModel(username: "test")
        checkForMemoryLeak(sut)
    }
    
    func test_detailViewController_doesNotCreateMemoryLeak() {
        let viewModel = UserDetailViewModel(username: "test")
        let sut = UserDetailViewController(viewModel: viewModel)
        checkForMemoryLeak(sut)
        
        sut.loadViewIfNeeded()
    }
}


extension XCTestCase {
    func checkForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
