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
        let users = createMockUsers(count: 20)
        mockUseCase.stubbedResult = .just(users)
        
        let stateObserver = scheduler.createObserver(ViewState.self)
        sut.outputs.state
            .bind(to: stateObserver)
            .disposed(by: disposeBag)
        
        // When
        scheduler.scheduleAt(10) {
            self.sut.inputs.viewDidLoad()
        }
        scheduler.start()
        
        // Then
        XCTAssertEqual(stateObserver.events.count, 3)
        
        // Initial state
        XCTAssertEqual(stateObserver.events[0].time, 0)
        XCTAssertEqual(stateObserver.events[0].value.element?.isLoading, false)
        XCTAssertEqual(stateObserver.events[0].value.element?.items.count, 0)
        
        // Loading state
        XCTAssertEqual(stateObserver.events[1].time, 10)
        XCTAssertEqual(stateObserver.events[1].value.element?.isLoading, true)
        XCTAssertEqual(stateObserver.events[1].value.element?.items.count, 0)
        
        // Success state
        XCTAssertEqual(stateObserver.events[2].time, 10)
        XCTAssertEqual(stateObserver.events[2].value.element?.isLoading, false)
        XCTAssertEqual(stateObserver.events[2].value.element?.items.count, users.count)
        
        // Verify users data
        let resultItems = stateObserver.events[2].value.element?.items ?? []
        for (index, item) in resultItems.enumerated() {
            XCTAssertEqual(item.login, users[index].login)
            XCTAssertEqual(item.avatarUrl, users[index].avatarUrl)
            XCTAssertEqual(item.htmlUrl, users[index].htmlUrl)
        }
        
        // Verify use case calls
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 1)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.since, 0)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.perPage, 20)
    }

    // MARK: - Pagination Tests

    func testLoadMore_ShouldFetchNextPage() {
        // Given
        let initialUsers = createMockUsers(count: 20)
        let nextPageUsers = createMockUsers(count: 20, startingIndex: 20)
        
        var isFirstLoad = true
        mockUseCase.executeHandler = { since, _ in
            if isFirstLoad {
                isFirstLoad = false
                return .just(initialUsers)
            } else {
                return .just(nextPageUsers)
            }
        }
        
        let stateObserver = scheduler.createObserver(ViewState.self)
        sut.outputs.state
            .bind(to: stateObserver)
            .disposed(by: disposeBag)
        
        // When
        scheduler.scheduleAt(10) {
            self.sut.inputs.viewDidLoad()
        }
        
        scheduler.scheduleAt(20) {
            self.sut.inputs.loadMore()
        }
        
        scheduler.start()
        
        // Then
        XCTAssertEqual(stateObserver.events.count, 5)
        
        // Initial state
        XCTAssertEqual(stateObserver.events[0].time, 0)
        XCTAssertEqual(stateObserver.events[0].value.element?.isLoading, false)
        XCTAssertEqual(stateObserver.events[0].value.element?.items.count, 0)
        
        // First load - Loading state
        XCTAssertEqual(stateObserver.events[1].time, 10)
        XCTAssertEqual(stateObserver.events[1].value.element?.isLoading, true)
        XCTAssertEqual(stateObserver.events[1].value.element?.items.count, 0)
        
        // First load - Success state
        XCTAssertEqual(stateObserver.events[2].time, 10)
        XCTAssertEqual(stateObserver.events[2].value.element?.isLoading, false)
        XCTAssertEqual(stateObserver.events[2].value.element?.items.count, initialUsers.count)
        
        // Load more - Loading state
        XCTAssertEqual(stateObserver.events[3].time, 20)
        XCTAssertEqual(stateObserver.events[3].value.element?.isLoading, true)
        XCTAssertEqual(stateObserver.events[3].value.element?.items.count, initialUsers.count)
        
        // Load more - Success state
        XCTAssertEqual(stateObserver.events[4].time, 20)
        XCTAssertEqual(stateObserver.events[4].value.element?.isLoading, false)
        XCTAssertEqual(stateObserver.events[4].value.element?.items.count, initialUsers.count + nextPageUsers.count)
        
        // Verify first page items
        let firstPageItems = stateObserver.events[2].value.element?.items ?? []
        for (index, item) in firstPageItems.enumerated() {
            XCTAssertEqual(item.login, initialUsers[index].login)
            XCTAssertEqual(item.avatarUrl, initialUsers[index].avatarUrl)
            XCTAssertEqual(item.htmlUrl, initialUsers[index].htmlUrl)
        }
        
        // Verify second page items
        let secondPageItems = stateObserver.events[4].value.element?.items.suffix(nextPageUsers.count) ?? []
        for (index, item) in secondPageItems.enumerated() {
            XCTAssertEqual(item.login, nextPageUsers[index].login)
            XCTAssertEqual(item.avatarUrl, nextPageUsers[index].avatarUrl)
            XCTAssertEqual(item.htmlUrl, nextPageUsers[index].htmlUrl)
        }
        
        // Verify use case calls
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 2)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.since, 20)
        XCTAssertEqual(mockUseCase.invokedExecuteParameters?.perPage, 20)
    }

    // MARK: - Error Tests
    
    func testInitialLoad_WhenError_ShouldUpdateStateAndEmitError() {
        // Given
        let expectedError = NSError(domain: "test", code: -1, userInfo: nil)
        mockUseCase.stubbedResult = .error(expectedError)
        
        let stateObserver = scheduler.createObserver(ViewState.self)
        let errorObserver = scheduler.createObserver(Error.self)
        
        sut.outputs.state
            .bind(to: stateObserver)
            .disposed(by: disposeBag)
        
        sut.outputs.error
            .bind(to: errorObserver)
            .disposed(by: disposeBag)
        
        // When
        scheduler.scheduleAt(10) {
            self.sut.inputs.viewDidLoad()
        }
        
        scheduler.start()
        
        // Then
        // Verify states
        XCTAssertEqual(stateObserver.events.count, 3)
        
        // Initial state
        XCTAssertEqual(stateObserver.events[0].time, 0)
        XCTAssertEqual(stateObserver.events[0].value.element?.isLoading, false)
        XCTAssertTrue(stateObserver.events[0].value.element?.items.isEmpty ?? false)
        
        // Loading state
        XCTAssertEqual(stateObserver.events[1].time, 10)
        XCTAssertEqual(stateObserver.events[1].value.element?.isLoading, true)
        XCTAssertTrue(stateObserver.events[1].value.element?.items.isEmpty ?? false)
        
        // Error state
        XCTAssertEqual(stateObserver.events[2].time, 10)
        XCTAssertEqual(stateObserver.events[2].value.element?.isLoading, false)
        XCTAssertTrue(stateObserver.events[2].value.element?.items.isEmpty ?? false)
        
        // Verify error
        XCTAssertEqual(errorObserver.events.count, 1)
        XCTAssertEqual(errorObserver.events[0].time, 10)
        XCTAssertEqual((errorObserver.events[0].value.element as NSError?)?.domain, expectedError.domain)
    }

    func testLoadMore_WhenError_ShouldUpdateStateAndEmitError() {
        // Given
        let initialUsers = createMockUsers(count: 20)
        let expectedError = NSError(domain: "test", code: -1, userInfo: nil)
        
        var isFirstLoad = true
        mockUseCase.executeHandler = { since, _ in
            if isFirstLoad {
                isFirstLoad = false
                return .just(initialUsers)
            } else {
                return .error(expectedError)
            }
        }
        
        let stateObserver = scheduler.createObserver(ViewState.self)
        let errorObserver = scheduler.createObserver(Error.self)
        
        sut.outputs.state
            .bind(to: stateObserver)
            .disposed(by: disposeBag)
        
        sut.outputs.error
            .bind(to: errorObserver)
            .disposed(by: disposeBag)
        
        // When
        scheduler.scheduleAt(10) {
            self.sut.inputs.viewDidLoad()
        }
        
        scheduler.scheduleAt(20) {
            self.sut.inputs.loadMore()
        }
        
        scheduler.start()
        
        // Then
        XCTAssertEqual(stateObserver.events.count, 5)
        
        // Initial state
        XCTAssertEqual(stateObserver.events[0].time, 0)
        XCTAssertEqual(stateObserver.events[0].value.element?.isLoading, false)
        XCTAssertTrue(stateObserver.events[0].value.element?.items.isEmpty ?? false)
        
        // First load - Loading state
        XCTAssertEqual(stateObserver.events[1].time, 10)
        XCTAssertEqual(stateObserver.events[1].value.element?.isLoading, true)
        XCTAssertTrue(stateObserver.events[1].value.element?.items.isEmpty ?? false)
        
        // First load - Success state
        XCTAssertEqual(stateObserver.events[2].time, 10)
        XCTAssertEqual(stateObserver.events[2].value.element?.isLoading, false)
        XCTAssertEqual(stateObserver.events[2].value.element?.items.count, initialUsers.count)
        
        // Load more - Loading state
        XCTAssertEqual(stateObserver.events[3].time, 20)
        XCTAssertEqual(stateObserver.events[3].value.element?.isLoading, true)
        XCTAssertEqual(stateObserver.events[3].value.element?.items.count, initialUsers.count)
        
        // Load more - Error state
        XCTAssertEqual(stateObserver.events[4].time, 20)
        XCTAssertEqual(stateObserver.events[4].value.element?.isLoading, false)
        XCTAssertEqual(stateObserver.events[4].value.element?.items.count, initialUsers.count)
        
        // Verify error
        XCTAssertEqual(errorObserver.events.count, 1)
        XCTAssertEqual(errorObserver.events[0].time, 20)
        XCTAssertEqual((errorObserver.events[0].value.element as NSError?)?.domain, expectedError.domain)
    }
    
    // MARK: - Helper Methods
    
    private func createMockUsers(count: Int, startingIndex: Int = 0) -> [User] {
        return (0..<count).map { index in
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
    var invokedExecuteParameters: (since: Int, perPage: Int)?
    var stubbedResult: Observable<[User]> = .just([])
    var executeHandler: ((Int, Int) -> Observable<[User]>)?
    
    func execute(since: Int, perPage: Int) -> Observable<[User]> {
        invokedExecuteCount += 1
        invokedExecuteParameters = (since, perPage)
        return executeHandler?(since, perPage) ?? stubbedResult
    }
}
