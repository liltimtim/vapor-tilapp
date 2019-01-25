//
//  UserController.swift
//  App
//
//  Created by Timothy Dillman  on 1/24/19.
//

import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let routeGroup = router.grouped("api", "users")
        // api/users
        routeGroup.post(User.self, use: createHandler)
        // api/users
        routeGroup.get(use: getHandler)
        // api/users/<id>
        routeGroup.get(User.parameter, use: findOneHandler)
        // api/users/<id>/acronyms
        routeGroup.get(User.parameter, "acronyms", use: getAcronyms)
    }
    
    func createHandler(_ r: Request, user: User) throws -> Future<User> {
        return user.save(on: r)
    }
    
    func getHandler(_ r: Request) throws -> Future<[User]> {
        return User.query(on: r).all()
    }
    
    func findOneHandler(_ r: Request) throws -> Future<User> {
        return try r.parameters.next(User.self)
    }
    
    func getAcronyms(_ r: Request) throws -> Future<[Acronym]> {
        return try r.parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                try user.acronyms.query(on: r).all()
        }
    }
    
}
