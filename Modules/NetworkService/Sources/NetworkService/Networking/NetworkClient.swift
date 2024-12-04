//
//  NetworkClient.swift
//  NetworkService
//
//  Created by Hận Lê on 12/2/24.
//

import Alamofire
import Moya
import RxSwift

public protocol NetworkClientProtocol {
   associatedtype Request: NetworkRequestable
   func request<R: Decodable>(_ request: Request) -> Single<R>
   func request(_ request: Request) -> Single<Void>
}

public final class NetworkClient<T: NetworkRequestable>: NetworkClientProtocol {
    public typealias Request = T
    private let provider: MoyaProvider<MultiTarget>
    private let decoder: JSONDecoder
    private let logger: NetworkLoggerProtocol
    
    public init(
        configuration: NetworkConfiguration = .default,
        decoder: JSONDecoder = JSONDecoder(),
        logger: NetworkLoggerProtocol = NetworkLogger()
    ) {
        self.provider = MoyaProvider(
            endpointClosure: configuration.endpointMapping,
            requestClosure: configuration.requestMapping,
            session: configuration.session,
            plugins: configuration.plugins
        )
        self.decoder = decoder
        self.logger = logger
    }
    
    public func request<R: Decodable>(_ request: T) -> Single<R> {
        let target = makeTarget(for: request)
        return provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .map(R.self, using: decoder)
            .catch { error -> Single<R> in
                self.logger.log(error: error, for: target)
                return .error(NetworkError.from(error))
            }
    }
    
    public func request(_ request: T) -> Single<Void> {
        let target = makeTarget(for: request)
        return provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .map { _ in }
            .catch { error -> Single<Void> in
                self.logger.log(error: error, for: target)
                return .error(NetworkError.from(error))
            }
    }
}

// MARK: - Private Extensions
private extension NetworkClient {
    func makeTarget(for request: NetworkRequestable) -> MultiTarget {
        let target = MultiTargetAdapter(
            baseURL: request.baseURL,
            path: request.path,
            method: request.method,
            parameters: request.parameters,
            headers: request.headers,
            authorizationType: request.authorizationType,
            sampleData: request.sampleData
        )
        return MultiTarget(target)
    }
}

private struct MultiTargetAdapter: TargetType {
    let baseURL: URL
    let path: String
    let method: Moya.Method
    let parameters: [String: Any]?
    let headers: [String: String]?
    let authorizationType: AuthorizationType?
    let sampleData: Data
    
    var task: Task {
        guard let parameters = parameters else { return .requestPlain }
        
        switch method {
        case .get:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .post, .put, .patch:
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

/**
 NetworkClient Usage Guide:
 
 1. Define API Target:
 ```swift
 enum UserAPI {
     case profile
     case update(name: String)
 }
 
 extension UserAPI: NetworkRequestable {
     var path: String {
         switch self {
         case .profile: return "user/profile"
         case .update: return "user/update"
         }
     }
     
     var parameters: [String: Any]? {
         switch self {
         case .profile: return nil
         case .update(let name): return ["name": name]
         }
     }
     
     var method: Moya.Method {
         switch self {
         case .profile: return .get
         case .update: return .post
         }
     }
     
     var authorizationType: AuthorizationType? {
         return .bearer
     }
 }
 
 2. Create Provider:
 ```swift
 typealias UserNetworking = NetworkClient<UserAPI>
 
 3. Repository Integration:
 ```swift
 final class UserRepository {
     private let networking = UserNetworking()
     
     func fetchProfile() -> Single<UserProfile> {
         return networking.request(UserAPI.profile)
     }
     
     func updateName(_ name: String) -> Single<Void> {
         return networking.request(UserAPI.update(name: name))
     }
 }
 ```
 
 Note: Response models must conform to Decodable protocol
 */
