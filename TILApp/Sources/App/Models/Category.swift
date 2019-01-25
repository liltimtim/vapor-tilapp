//
//  Category.swift
//  App
//
//  Created by Timothy Dillman  on 1/25/19.
//

import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: Content { }
extension Category: PostgreSQLModel { }
extension Category: Parameter { }
extension Category: Migration { }
