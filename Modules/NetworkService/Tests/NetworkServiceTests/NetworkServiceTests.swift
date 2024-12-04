//
//  NetworkServiceTests.swift
//  NetworkService-NetworkService
//
//  Created by Hận Lê on 12/2/24.
//

import Moya
@testable import NetworkService
import RxSwift
import XCTest

final class NetworkServiceTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var mockClient: MockNetworkClient<MockAPI>!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    func testSuccessfulRequest() {
        let mockData = """
        {"id": 1,"name": "Test User"}
        """.data(using: .utf8)!

        mockClient = MockNetworkClient(mockResult: .success(mockData))

        let expectation = XCTestExpectation()
        var result: MockUser?

        mockClient.request(MockAPI.user)
            .subscribe(onSuccess: { (response: MockUser) in
                result = response
                expectation.fulfill()
            }, onFailure: { XCTFail($0.localizedDescription) })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(result?.id, 1)
        XCTAssertEqual(result?.name, "Test User")
    }

    func testFailedRequest() {
        let mockError = NetworkError.invalidResponse
        mockClient = MockNetworkClient(mockResult: .failure(mockError))

        let expectation = XCTestExpectation()
        var receivedError: NetworkError?

        mockClient.request(MockAPI.user)
            .subscribe(
                onSuccess: { (_: MockUser) in XCTFail("Expected failure") },
                onFailure: {
                    receivedError = $0 as? NetworkError
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedError, mockError)
    }
}

// MARK: - Test Helpers

private struct MockUser: Decodable {
    let id: Int
    let name: String
}

private enum MockAPI {
    case user
}

extension MockAPI: NetworkRequestable {
    var baseURL: URL { URL(string: "https://api.test.com")! }
    var path: String { "/user" }
    var method: Moya.Method { .get }
    var parameters: [String: Any]? { nil }
    var headers: [String: String]? { nil }
    var authorizationType: Moya.AuthorizationType? { nil }
}

private final class MockNetworkClient<T: NetworkRequestable>: NetworkClientProtocol {
    typealias Request = T
    let mockResult: Result<Data, Error>

    init(mockResult: Result<Data, Error>) {
        self.mockResult = mockResult
    }

    func request<R>(_: T) -> Single<R> where R: Decodable {
        switch mockResult {
        case let .success(data):
            return .just(try! JSONDecoder().decode(R.self, from: data))
        case let .failure(error):
            return .error(error)
        }
    }

    func request(_: T) -> Single<Void> {
        switch mockResult {
        case .success:
            return .just(())
        case let .failure(error):
            return .error(error)
        }
    }
}
