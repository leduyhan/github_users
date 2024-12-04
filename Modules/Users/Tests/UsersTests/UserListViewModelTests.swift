@testable import Domain
import RxSwift
import RxTest
@testable import Users
import XCTest

final class UserListViewModelTests: XCTestCase {
    private var sut: UserListViewModel!
    private var mockUseCase: MockFetchUsersUseCase!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchUsersUseCase()
        sut = UserListViewModel(useCase: mockUseCase)
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        disposeBag = nil
        scheduler = nil
        super.tearDown()
    }

    // MARK: - Initial Load Tests

    func testViewDidLoad_ShouldFetchInitialUsers() {
        // Given
        let expectation = expectation(description: "Initial load")
        let users = createMockUsers(count: 20)
        mockUseCase.stubbedResult = .just(users)

        var receivedItems: [UserCellItem] = []
        var receivedLoadingStates: [LoadingState] = []
        var loadingCompleted = false

        // Then
        sut.outputs.loadingState
            .skip(1) // Skip initial .none state
            .subscribe(onNext: { state in
                receivedLoadingStates.append(state)
                if state == .none {
                    loadingCompleted = true
                }
            })
            .disposed(by: disposeBag)

        sut.outputs.items
            .subscribe(onNext: { items in
                receivedItems = items
                if !items.isEmpty, loadingCompleted {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        // When
        self.sut.inputs.viewDidLoad()

        wait(for: [expectation], timeout: 0.1)

        // Verify use case was called correctly
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 1)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.since, 0)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.perPage, 20)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.forceRefresh, false)

        // Verify received items
        XCTAssertEqual(receivedItems.count, users.count)

        // Verify loading states
        XCTAssertEqual(receivedLoadingStates, [.initial, .none])
    }

    // MARK: - Pagination Tests

    func testLoadMore_ShouldFetchNextPage() {
        // Given
        let initialExpectation = expectation(description: "Initial load")
        let loadMoreExpectation = expectation(description: "Load more")
        
        let initialUsers = createMockUsers(count: 20)
        let nextPageUsers = createMockUsers(count: 20, startingIndex: 20)
        
        var isFirstLoad = true
        mockUseCase.executeHandler = { since, _, _ in
            if isFirstLoad {
                isFirstLoad = false
                return .just(initialUsers)
            } else {
                return .just(nextPageUsers)
            }
        }
        
        var receivedItems: [UserCellItem] = []
        var receivedLoadingStates: [LoadingState] = []
        
        // Then
        sut.outputs.loadingState
            .skip(1) // Skip initial .none state
            .subscribe(onNext: { state in
                receivedLoadingStates.append(state)
            })
            .disposed(by: disposeBag)
        
        sut.outputs.items
            .subscribe(onNext: { items in
                receivedItems = items
                if items.count == initialUsers.count {
                    initialExpectation.fulfill()
                } else if items.count == initialUsers.count + nextPageUsers.count {
                    loadMoreExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        // When - First load initial page
        sut.inputs.viewDidLoad()
        
        // Wait for initial load
        wait(for: [initialExpectation], timeout: 1.0)
        
        // Then load next page
        sut.inputs.loadMore()
        
        // Wait for load more
        wait(for: [loadMoreExpectation], timeout: 1.0)
        
        // Verify use case was called correctly
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 2)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.since, 20) // Second page
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.perPage, 20)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.forceRefresh, false)
        
        // Verify received items contains both pages
        XCTAssertEqual(receivedItems.count, initialUsers.count + nextPageUsers.count)
        
        // Verify loading states
        XCTAssertEqual(receivedLoadingStates, [.initial, .none, .pagination, .none])
    }
    
    func testViewDidLoad_WhenError_ShouldEmitError() {
        // Given
        let expectation = expectation(description: "Error emitted")
        let expectedError = NSError(domain: "test", code: -1, userInfo: nil)
        mockUseCase.stubbedResult = .error(expectedError)
        
        var receivedError: Error?
        var receivedLoadingStates: [LoadingState] = []
        
        // Then
        sut.outputs.loadingState
            .skip(1) // Skip initial .none state
            .subscribe(onNext: { state in
                receivedLoadingStates.append(state)
            })
            .disposed(by: disposeBag)
        
        sut.outputs.error
            .subscribe(onNext: { error in
                receivedError = error
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // When
        sut.inputs.viewDidLoad()
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 1)
        XCTAssertEqual((receivedError as NSError?)?.domain, expectedError.domain)
        XCTAssertEqual(receivedLoadingStates, [.initial, .none])
    }

    func testLoadMore_WhenError_ShouldEmitError() {
        // Given
        let initialExpectation = expectation(description: "Initial load")
        let errorExpectation = expectation(description: "Error emitted")
        
        let initialUsers = createMockUsers(count: 20)
        let expectedError = NSError(domain: "test", code: -1, userInfo: nil)
        
        var isFirstLoad = true
        mockUseCase.executeHandler = { since, _, _ in
            if isFirstLoad {
                isFirstLoad = false
                return .just(initialUsers)
            } else {
                return .error(expectedError)
            }
        }
        
        var receivedError: Error?
        var receivedLoadingStates: [LoadingState] = []
        
        // Then
        sut.outputs.loadingState
            .skip(1) // Skip initial .none state
            .subscribe(onNext: { state in
                receivedLoadingStates.append(state)
            })
            .disposed(by: disposeBag)
        
        sut.outputs.items
            .subscribe(onNext: { items in
                if items.count == initialUsers.count {
                    initialExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        sut.outputs.error
            .subscribe(onNext: { error in
                receivedError = error
                errorExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // When - First load initial page
        sut.inputs.viewDidLoad()
        
        // Wait for initial load
        wait(for: [initialExpectation], timeout: 1.0)
        
        // Then load next page which will error
        sut.inputs.loadMore()
        
        // Wait for error
        wait(for: [errorExpectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 2)
        XCTAssertEqual((receivedError as NSError?)?.domain, expectedError.domain)
        XCTAssertEqual(receivedLoadingStates, [.initial, .none, .pagination, .none])
    }
    
    // MARK: - Helper Methods
    private func createMockUsers(count: Int, startingIndex: Int = 0) -> [User] {
        return (0 ..< count).map { index in
            User(
                login: "user\(startingIndex + index)",
                avatarUrl: "https://example.com/avatar\(startingIndex + index)",
                htmlUrl: "https://example.com/user\(startingIndex + index)"
            )
        }
    }
}

// MARK: - Mock Use Case

private final class MockFetchUsersUseCase: FetchUsersUseCase {
    var invokedExecuteCount = 0
    var invokedExecuteParameters: (since: Int, perPage: Int, forceRefresh: Bool)?
    var stubbedResult: Observable<[User]> = .just([])
    var executeHandler: ((Int, Int, Bool) -> Observable<[User]>)?
    
    func execute(since: Int, perPage: Int, forceRefresh: Bool) -> Observable<[User]> {
        invokedExecuteCount += 1
        invokedExecuteParameters = (since, perPage, forceRefresh)
        return executeHandler?(since, perPage, forceRefresh) ?? stubbedResult
    }
}
