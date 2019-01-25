# Controllers

**Controllers**: serve similar purpose to controllers in iOS. Handle interactions from a client, process requests, and return responses. `Good practice is to have all interactions with a model in a dedicated controller`.

## Route Collections

Route collections allow the controller to manage a collection of defined routes on to the router. In order for a controller to be a collection of route it must conform to `RouteCollection` protocol

### Route Collection Protocol

```Swift
import Vapor
import Fluent

struct ExampleController: RouteCollection {
  func boot(router: Router) throws {

  }
}
```

The `RouteCollection` protocol requires the `boot(router:)` function which takes in a router. This is where you will define all the following routes.

Inside the `routes.swift` file we need to register this controller

```Swift
func routes(_ router: Router) throws {
  let exampleController = ExampleController()
  router.register(collection: exampleController)
}
```

The above code lets the router know that the controller conforms to RouteCollection and serves up routes.

### Route Groups

This allows controllers to define a `grouping` for routes. So far, most routes have been `/api/acronyms` however we've had to define all the routes as `router.get("api", "acronyms")`. This is solved by route groups.

**This is very similar to Express's `app.use(<route>, function)` method.**

To create a grouping....

**ExampleController.swift**

```Swift
import Vapor
import Fluent

struct ExampleController: RouteCollection {
  func boot(router: Router) throws {
    let routeGroup = router.grouped("api", "acronyms")
    routeGroup.get(use: getAllHandler)
  }
}
```

Recall that the `.get()` method also has an overload for a function.

A `route handler` is very similar except that its just a function. It still returns a Future.

```Swift
func someHandler(_ req: Request) throws -> Future<Object> {
  return Object.query(on: req).all()
}
```

**note** that technically the underscore is not necessary here since its understood the item is not named. The compiler will not complain if its left out.
