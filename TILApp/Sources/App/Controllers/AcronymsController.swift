//
//  File.swift
//  App
//
//  Created by Timothy Dillman  on 1/24/19.
//

import Foundation
import Vapor

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let routeGroup = router.grouped("api", "acronyms")
        // api/acronyms
        routeGroup.get(use: getAllHandler)
        // api/acronyms/<id>
        routeGroup.get(Acronym.parameter, use: getHandler)
        // api/acronyms/search
        routeGroup.get("search", use: searchHandler)
        // api/acronyms/sorted
        routeGroup.get("sorted", use: sortedHandler)
        // api/acronyms
        routeGroup.post(use: createHandler)
        // api/acronyms/<id>
        routeGroup.put(use: updateHandler)
        // api/acronyms/<id>
        routeGroup.delete(Acronym.parameter, use: deleteHandler)
        // api/acronyms/<id>/user
        
        
        /*
        router.post("api", "acronyms") { r -> Future<Acronym> in
            // decode the body
            //        let body = try r.content.decode(Acronym.self)
            //        body.flatMap({ (acronym) -> Future<Acronym> in
            //            return acronym.save(on: r)
            //        })
            return try r.content.decode(Acronym.self).flatMap(to: Acronym.self, { acronym in
                return acronym.save(on: r)
            })
        }
        
        router.get("api", "acronyms") { r -> Future<[Acronym]> in
            return Acronym.query(on: r).all()
        }
        
        router.get("api", "acronyms", Acronym.parameter) { r -> Future<Acronym> in
            return try r.parameters.next(Acronym.self)
        }
        
        router.put("api", "acronyms", Acronym.parameter) { r -> Future<Acronym> in
            return try flatMap(
                to: Acronym.self,
                r.parameters.next(Acronym.self),
                r.content.decode(Acronym.self)) { acronym, updatedAcronym in
                    acronym.short = updatedAcronym.short
                    acronym.long = updatedAcronym.long
                    return acronym.save(on: r)
            }
        }
        
        router.delete("api", "acronyms", Acronym.parameter) { r -> Future<HTTPStatus> in
            return try r.parameters.next(Acronym.self).delete(on: r).transform(to: HTTPStatus.noContent)
        }
        
        router.get("api", "acronyms", "search") { r -> Future<[Acronym]> in
            guard let searchTerm = r.query[String.self, at: "term"] else { throw Abort(.badRequest) }
            //        return Acronym.query(on: r)
            //            .filter(\Acronym.short == searchTerm)
            //            .all()
            //
            // Using an OR query
            return Acronym.query(on: r).group(.or, closure: { (or) in
                or.filter(\Acronym.short, .equal, searchTerm)
                or.filter(\Acronym.long, .equal, searchTerm)
            }).all()
        }
        
        router.get("api", "acronyms", "sorted") { r -> Future<[Acronym]> in
            return Acronym.query(on: r)
                .sort(\Acronym.short, .ascending)
                .all()
        }
         */
    }
    
    func getAllHandler(_ r: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: r).all()
    }
    
    func getHandler(_ r: Request) throws -> Future<Acronym> {
        return try r.parameters.next(Acronym.self)
    }
    
    func createHandler(_ r: Request) throws -> Future<Acronym> {
        return try r.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            return acronym.save(on: r)
        }
    }
    
    func updateHandler(_ r: Request) throws -> Future<Acronym> {
        return try flatMap(r.parameters.next(Acronym.self), r.content.decode(Acronym.self)) { acronym, decoded in
            acronym.short = decoded.short
            acronym.long = decoded.long
            acronym.userID = decoded.userID
            return acronym.save(on: r)
        }
    }
    
    func deleteHandler(_ r: Request) throws -> Future<HTTPStatus> {
        return try r.parameters.next(Acronym.self).delete(on: r).transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ r: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = r.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: r).group(.or) { query in
            query.filter(\.short, .equal, searchTerm)
            query.filter(\.long, .equal, searchTerm)
        }.all()
    }
    
    func sortedHandler(_ r: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: r).sort(\Acronym.short, .ascending).all()
    }
    
//    func getUserHandler(_ r: Request) throws -> Future<User> {
//        return try r.parameters.next(Acronym.self)
//            // 1
//            .flatMap(to: User.self) { acronym in
//                // 2
//                acronym.user.get(on: r)
//        }
//    }
    
    func getUserHandler(_ r: Request) throws -> Future<User> {
        return try r.parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                acronym.user.get(on: r)
        }
    }
}
