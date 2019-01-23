# Hello Vapor

Routes can take more than just a `String` Parameter type. There's also JSON.

Vapor integrates strongly with the Swift `Codable` type. This allows for very easy encoding and decoding of JSON objects.

We can define a very basic JSON codable structure and have the client pass this in as a POST body request parameter.

Function signature for `.post()` method

```Swift
// Our simple struct
struct InfoData: Content {
    let name: String
}

```

**Content** : is a Vapor wrapper for the Swift `codable` type.

From the docs:

```Swift
protocol Content : Decodable, Encodable, RequestDecodable, RequestEncodable, ResponseDecodable, ResponseEncodable
```

As shown, the Content protocol conforms to Decodable and Encodable swift type.

```Swift
router.post(<#T##content: RequestDecodable.Protocol##RequestDecodable.Protocol#>, at: <#T##PathComponentsRepresentable...##PathComponentsRepresentable#>, use: <#T##(Request, RequestDecodable) throws -> ResponseEncodable#>)
```

In practice this looks like the following

```Swift
router.post(InfoData.self, at: "info") { req, data -> String in
  return "Hello, \(data.name)"
}
```

## Returning JSON Content

First create a struct to hold the response we will send back to the client.

```Swift
struct InfoResponse: Content {
  let request: InfoData
}
```

Next we must make our endpoint return the "JSON" type. Since our `InfoResponse` conforms to `Content` we don't need to worry about encoding it into JSON

```Swift
router.post(InfoData.self, at: "hello", "info") { req, data in -> InfoResponse
  return InfoResponse(request: data)
}
```
