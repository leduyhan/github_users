//
//  UserAPI.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import NetworkService

public enum UserAPI {
    case users(since: Int, perPage: Int)
    case userDetail(username: String)
}

extension UserAPI: NetworkRequestable {
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    public var path: String {
        switch self {
        case .users:
            return "/users"
        case let .userDetail(username):
            return "/users/\(username)"
        }
    }

    public var method: APIMethod {
        return .get
    }

    public var parameters: [String: Any]? {
        switch self {
        case let .users(since, perPage):
            return [
                "since": since,
                "per_page": perPage,
            ]
        case .userDetail:
            return nil
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json;charset=utf-8"]
    }

    public var authorizationType: APIAuthorizationType? {
        nil
    }
}
