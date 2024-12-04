//
//  UserDetailViewModelTests.swift
//  Users-Unit-UsersTests
//
//  Created by Hận Lê on 12/4/24.
//

@testable import Domain
import RxSwift
import RxTest
@testable import Users
import XCTest

final class UserDetailViewModelTests: XCTestCase {
    private var sut: UserDetailViewModel!
    private var mockUseCase: MockFetchUserDetailUseCase!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private let testUsername = "testUser"

    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchUserDetailUseCase()
        sut = UserDetailViewModel(username: testUsername, useCase: mockUseCase)
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

    // MARK: - Tests

    func testViewDidLoad_ShouldFetchUserDetail() {
        // Given
        let expectation = expectation(description: "User detail loaded")
        let mockUser = createMockUser()
        var receivedUser: UserDetail?
        mockUseCase.stubbedResult = .just(mockUser)

        // Then
        sut.outputs.user
            .subscribe(onNext: { user in
                receivedUser = user
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        sut.inputs.viewDidLoad()

        wait(for: [expectation], timeout: 0.1)

        // Verify
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 1)
        XCTAssertEqual(mockUseCase.invokedUsername, testUsername)

        // Verify each field matches
        XCTAssertEqual(receivedUser?.login, mockUser.login)
        XCTAssertEqual(receivedUser?.avatarUrl, mockUser.avatarUrl)
        XCTAssertEqual(receivedUser?.htmlUrl, mockUser.htmlUrl)
        XCTAssertEqual(receivedUser?.location, mockUser.location)
        XCTAssertEqual(receivedUser?.followers, mockUser.followers)
        XCTAssertEqual(receivedUser?.following, mockUser.following)
    }

    func testViewDidLoad_WhenError_ShouldNotEmitUser() {
        // Given
        let expectation = expectation(description: "Error case")
        expectation.isInverted = true // We expect no user emission
        let expectedError = NSError(domain: "test", code: -1, userInfo: nil)
        mockUseCase.stubbedResult = .error(expectedError)

        // Then
        sut.outputs.user
            .subscribe(onNext: { _ in
                expectation.fulfill() // Should not be called
            })
            .disposed(by: disposeBag)

        // When
        sut.inputs.viewDidLoad()

        wait(for: [expectation], timeout: 0.1)

        // Verify
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 1)
    }

    func testViewDidLoad_EmitsLatestUserDetail() {
        // Given
        let expectation = expectation(description: "Updated user detail")
        let initialUser = createMockUser(followers: 100, following: 50)
        let updatedUser = createMockUser(followers: 150, following: 75)

        var emissionCount = 0
        var receivedUsers: [UserDetail] = []

        mockUseCase.executeHandler = { _ in
            emissionCount += 1
            return .just(emissionCount == 1 ? initialUser : updatedUser)
        }

        // Then
        sut.outputs.user
            .subscribe(onNext: { user in
                receivedUsers.append(user)
                if receivedUsers.count == 2 {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        // When
        sut.inputs.viewDidLoad()
        sut.inputs.viewDidLoad() // Trigger second load

        wait(for: [expectation], timeout: 0.1)

        // Verify
        XCTAssertEqual(mockUseCase.invokedExecuteCount, 2)
        XCTAssertEqual(receivedUsers.count, 2)
        XCTAssertEqual(receivedUsers[0].followers, 100)
        XCTAssertEqual(receivedUsers[1].followers, 150)
    }

    // MARK: - Helper Methods

    private func createMockUser(followers: Int = 100, following: Int = 50) -> UserDetail {
        return UserDetail(
            login: testUsername,
            avatarUrl: "https://example.com/avatar",
            htmlUrl: "https://example.com/user",
            location: "Test Location",
            followers: followers,
            following: following
        )
    }
}

// MARK: - Mock Use Case

private final class MockFetchUserDetailUseCase: FetchUserDetailUseCase {
    var invokedExecuteCount = 0
    var invokedUsername: String?
    var stubbedResult: Single<UserDetail> = .never()
    var executeHandler: ((String) -> Single<UserDetail>)?

    func execute(username: String) -> Single<UserDetail> {
        invokedExecuteCount += 1
        invokedUsername = username
        return executeHandler?(username) ?? stubbedResult
    }
}
