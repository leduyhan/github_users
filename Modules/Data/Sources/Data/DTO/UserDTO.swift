//
//  UserDTO.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public struct UserDTO: Decodable {
    let login: String
    let avatar_url: String
    let html_url: String
}
