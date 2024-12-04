//
//  NetworkLogger.swift
//  NetworkService
//
//  Created by Hận Lê on 12/2/24.
//

import Moya

public protocol NetworkLoggerProtocol {
    func log(error: Error, for target: TargetType)
}

public final class NetworkLogger: NetworkLoggerProtocol {
    public init() {}
    
    public func log(error: Error, for target: TargetType) {
        guard let moyaError = error as? MoyaError,
              let response = moyaError.response else {
            debugPrint("🌐 ❌ ERROR: \(error.localizedDescription)")
            return
        }
        
        let statusCode = response.statusCode
        let errorDescription = moyaError.errorDescription ?? ""
        
        if let jsonObject = try? response.mapJSON(failsOnEmptyData: false) {
            debugPrint("🌐 ❌ FAILURE [\(statusCode)] - \(target.baseURL)\(target.path): \(errorDescription)\n\(jsonObject)")
        } else {
            debugPrint("🌐 ❌ FAILURE [\(statusCode)] - \(target.baseURL)\(target.path): \(errorDescription)")
        }
    }
}
