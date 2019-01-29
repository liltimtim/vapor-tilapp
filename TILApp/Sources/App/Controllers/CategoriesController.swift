//
//  CategoriesController.swift
//  App
//
//  Created by Timothy Dillman  on 1/25/19.
//

import Vapor

struct CategoriesController: RouteCollection {
    func boot(router: Router) throws {
        let grouping = router.grouped("api", "categories")
        grouping.post(Category.self, use: createHandler)
        grouping.put(use: updateHandler)
        grouping.get(use: getHandler)
        grouping.get(Category.parameter, use: getOneHandler)
        grouping.get(Category.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func getHandler(_ r: Request) throws -> Future<[Category]> {
        // return all Categories
        return Category.query(on: r).all()
    }
    
    func getOneHandler(_ r: Request) throws -> Future<Category> {
        return try r.parameters.next(Category.self)
    }
    
    func createHandler(_ r: Request, category: Category) throws -> Future<Category> {
        return category.save(on: r)
    }
    
    func updateHandler(_ r: Request) throws -> Future<Category> {
        // update the category with new name
        return try flatMap(r.parameters.next(Category.self), r.content.decode(Category.self)) { category, decoded in
            category.name = decoded.name
            return category.save(on: r)
        }
    }
    
    func removeHandler(_ r: Request) throws -> Future<HTTPStatus> {
        return try r.parameters.next(Category.self).delete(on: r).transform(to: HTTPStatus.noContent)
    }
    
    func getAcronymsHandler(_ r: Request) throws -> Future<[Acronym]> {
        return try r.parameters.next(Category.self).flatMap(to: [Acronym].self) { c in
            try c.acronyms.query(on: r).all()
        }
    }
}
