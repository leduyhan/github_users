//
//  NetworkConfiguration.swift
//  NetworkService
//
//  Created by Hận Lê on 12/2/24.
//

import Alamofire
import Moya
import RxSwift

public struct NetworkConfiguration {
    let endpointMapping: MoyaProvider<MultiTarget>.EndpointClosure
    let requestMapping: MoyaProvider<MultiTarget>.RequestClosure
    let session: Session
    let plugins: [PluginType]

    public static let `default` = NetworkConfiguration(
        endpointMapping: { target in
            MoyaProvider.defaultEndpointMapping(for: target)
        },
        requestMapping: { endpoint, closure in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = 60
                request.httpShouldHandleCookies = true
                closure(.success(request))
            } catch {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        },
        session: MoyaProvider<MultiTarget>.defaultAlamofireSession(),
        plugins: []
    )
}
