# Starting Vapor Project

1. vapor new <project_name>
2. cd <project_name>
3. vapor build && vapor run

Typically this opens up a server running on port `8080` at `http://localhost:8080`

## Swift Package Manager

Vapor relies heavily on the `Swift Package Manager` to generate project. This means that XCode Projects / Workspaces are never committed into the github repo and are generated newly each time the project needs to be spun up.

This also means that you don't need XCode to run or build the application.

## main.swift

The main entry point for all Vapor and Swift apps.

# Creating XCode Project

1. vapor xcode -y

Tells vapor to generate an xcode project and passes in the "yes" parameter when prompting to open xcode after project is generated.

## Configuring Routes

Routes are genereally defined in the `Routes.swift` file.

The general structure of a route signature is...

```Swift
// router.<http_method>("route_param_name", callback)
router.get("hello") { req -> String in
  return "Hello Vapor!"
}
```

The compiler now knows that this callback produces a `String` return value for the route `hello`. This would now be accessible as a `GET` request on URL `http://localhost:8080/hello`

**App/routes.swift**

```Swift
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("hello", "vapor") { (req) -> String in
        return "Hello Vapor!"
    }
}
```

Above is a full example of defining a route inside the "routes" function.

### Defining Parameter inputs

```Swift
// Define a parameter of type String
router.get("hello", String.parameter) { req -> String in
    let name = try req.parameters.next(String.self)
    return "Hello, \(name)"
}
```

Tells us that a parameter of type "String" is inside the URL path. We take this string passed into the `Parameters` object on the `Request` and perform the `next()` operation on it. `next()` Grabs the next parameter from the parameter bag. Since **order** matters when defining the route path, calling next will always return the next param that was defined in the order it was received.
