//
//  NetworkError.swift
//  NetworkService
//
//  Created by Hận Lê on 12/2/24.
//

import Moya

public enum NetworkError: LocalizedError, Equatable {
    case invalidResponse
    case decodingFailed
    case underlying(Error)
    case statusCode(Int, Data?)
    case unauthorized
    case noInternet
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response received"
        case .decodingFailed: return "Failed to decode response"
        case .underlying(let error): return error.localizedDescription
        case .statusCode(let code, _): return "Request failed with status code: \(code)"
        case .unauthorized: return "Unauthorized access"
        case .noInternet: return "No internet connection"
        }
    }
    
    static func from(_ error: Error) -> NetworkError {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case let .statusCode(response):
                return .statusCode(response.statusCode, response.data)
            case let .underlying(underlyingError, _):
                if let urlError = underlyingError as? URLError,
                   urlError.code == .notConnectedToInternet {
                    return .noInternet
                }
                return .underlying(underlyingError)
            case let .objectMapping(error, _),
                 let .encodableMapping(error),
                 let .parameterEncoding(error):
                return .underlying(error)
            case .imageMapping, .jsonMapping, .stringMapping:
                return .decodingFailed
            case .requestMapping:
                return .invalidResponse
            }
        }
        return .underlying(error)
    }
}

extension NetworkError {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.decodingFailed, .decodingFailed),
             (.unauthorized, .unauthorized),
             (.noInternet, .noInternet):
            return true
        case let (.statusCode(lCode, lData), .statusCode(rCode, rData)):
            return lCode == rCode && lData == rData
        case (.underlying(let lError), .underlying(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
}
