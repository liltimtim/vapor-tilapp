//
//  AcronymCategoryPivot.swift
//  App
//
//  Created by Timothy Dillman  on 1/29/19.
//
import FluentPostgreSQL
import Foundation
// conform to Fluents ModifiablePivot and UUID ID model
final class AcronymCategoryPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    // define the model relationship (what is this pivot storing)
    typealias Left = Acronym
    
    typealias Right = Category
    
    var id: UUID?
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ left: AcronymCategoryPivot.Left, _ right: AcronymCategoryPivot.Right) throws {
        self.acronymID = try left.requireID()
        self.categoryID = try right.requireID()
    }
    
}

// register a migration
extension AcronymCategoryPivot: Migration { }
