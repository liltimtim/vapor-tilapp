import Vapor
import Fluent
/// Register your application's routes here.
public func routes(_ router: Router) throws {
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
}
