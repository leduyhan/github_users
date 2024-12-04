//
//  NetworkTypes.swift
//  NetworkService
//
//  Created by Hận Lê on 12/2/24.
//

import Moya
import RxSwift

public typealias APIMethod = Moya.Method
public typealias APIAuthorizationType = Moya.AuthorizationType

public protocol NetworkRequestable {
    var baseURL: URL { get }
    var path: String { get }
    var method: APIMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var authorizationType: APIAuthorizationType? { get }
    var sampleData: Data { get }
}

public extension NetworkRequestable {
    var sampleData: Data {
        Data()
    }
}

public protocol NetworkingService {
    func request<T: Decodable>(_ request: NetworkRequestable) -> Single<T>
    func request(_ request: NetworkRequestable) -> Single<Void>
}
