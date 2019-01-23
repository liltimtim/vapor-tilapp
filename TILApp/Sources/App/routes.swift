import Vapor

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
}
