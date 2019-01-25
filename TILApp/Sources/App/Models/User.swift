//
//  User.swift
//  App
//
//  Created by Timothy Dillman  on 1/24/19.
//

import Foundation
import FluentPostgreSQL
import Fluent
import Vapor

struct User: Codable {
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User: PostgreSQLUUIDModel { }

extension User: Content { } 

extension User: Parameter { }

extension User: Migration { }

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\Acronym.userID)
    }
}
