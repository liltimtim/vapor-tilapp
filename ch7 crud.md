# DB Crud operations

- Note that its required to have PostgreSQL setup before attempting these notes

## Retrieval of Documents

Register a route to get acronyms routes

```Swift
router.get("api", "acronyms") { req -> Future<[Acronym]> in
  return Acronym.query(on: req).all()
}
```

The `.all()` command will return all object types in the database. Similar to `SELECT * FROM Acronyms`. Use with caution especially if a large amount of items exist.

### Retrieval of Single Acronym

Vapor uses `Parameter` to remain type safe. This allows querying on the properties of defined Objects.

Example usage:

```Swift
router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
  return try req.parameters.next(Acronym.self)
}
```

This allows the ID to be extracted from the input parameters. Recall that `parameters.next()` returns the next sequential param item in the input sequence. In this case, its the `ID` type property of an Acronym object.

### Update an Acronym

```Swift
// 1
router.put("api", "acronyms",
Acronym.parameter) { req -> in
  // 2
  return try flatMap(
    to: Acronym.self,
    req.parameters.next(Acronym.self),
    req.content.decode(Acronym.self)) { acronym, updatedAcronym in
      // 3
      acronym.short = updatedAcronym.short
      acronym.long = updatedAcronym.long
      // 4
      return acronym.save(on: req)
    }
}
```

1. we register a "PUT" route onto the router `/api/acronyms/<ID>`

2. Recalling that flatMap allows the execution of up to 5 Futures of differing types, we use this to first find an acronym with the given ID parameter, then we decode the request body into an acronym object. **We can fetch this Acronym because it conforms to Parameter Protocol**

3. Once both futures have finished, we then take the found acronym and the updated acronym and replace the values

4. we then save the acronym

### Delete Acronym

```Swift
// 1
router.delete("api", "acronyms", Acronym.parameter) { r -> Future<HTTPStatus> in
  // 2
  return r.parameters.next(Acronym.self)
  // 3
    .delete(on: r)
    // 4
    .transform(to: HTTPStatus.noContent)
}
```

1. Register a new "DELETE" route with the router

2. Using the `.next()` method we find the Acronym object

3. We then perform a DB `.delete()` operation on the Request worker queue

4. Since we want to return a Future HTTPStatus we need to transform the return to .noContent (HTTP 204)

### Filtering with Fluent Queries

**Make sure to `import Fluent` when creating queries**

```Swift
// 1
router.get("api", "acronyms", "search") { r -> Future<[Acronym]> in
// 2
  guard let searchTerm = req.query[String.self at: "term"] else {
    throw Abort(.badRequest)
  }
  // 3
  return Acronym.query(on: r)
    // 4
    .filter(\.short == searchTerm)
    // 5
    .all()
}
```

1. Register a route with the router

2. extract the query with key `term` from the URL. `/api/acronyms/search?term=<some_term>` otherwise abort and throw a bad request error.

3. We ask for a query future on the Request worker.

4. We then do a filter on the `keyPath` `.short` on the Acronym object

5. We then return all the results using the resolved Future promise.

### Filtering on Multiple Properties

To filter on multiple properties you cannot chain `.filter()` queries. You must create a **Filter Group**

```Swift
return Acronym.query(on: r)
// 1
  .group(.or) { or in
  // 2
    or.filter(\.short == searchTerm)
    // 3
    or.filter(\.long == searchTerm)
  }.all() // 4
```

1. Create a filter group with the Binary operator of "or"

2. add a condition to check against property

3. add another condition to check

4. Return those results in a resolved Future array of Acronym objects

Example in long form

```Swift
return Acronym.query(on: r).group(.or, closure: { (or) in
    or.filter(\Acronym.short, .equal, searchTerm)
    or.filter(\Acronym.long, .equal, searchTerm)
}).all()
```

### First Result

If application requires only the first result of a query

```Swift
router.get("api", "acronyms", "first") { r -> Future<Acronym> in
  return Acronym.query(on: r).first().map(to: Acronym.self) { acronym in
    guard let acronym = acronym else {
      throw Abort(.notFound)
    }
    return acronym
  }
}
```

### Sorting Results

```Swift
router.get("api", "acronyms", "sorted") { r -> Future<[Acronym]> in
  return Acronym.query(on: r)
  // 1
    .sort(\.short, .ascending)
    .all()
}
```

Signature of sort takes in the Keypath of Acronym and the GenericSQLDirection.

```Swift
.sort(key: \Acronym.short, .ascending)
```
