//
//  UserDetailDTO.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public struct UserDetailDTO: Decodable {
    let login: String
    let avatar_url: String
    let html_url: String
    let location: String?
    let followers: Int
    let following: Int
}
