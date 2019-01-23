# Async

Vapor 3's most important feaeture is asynchronous and non-blocking architecture.

## Futures and Promises

Standard Synchronous function method

```Swift
func getAllUsers() -> [User] {
  // return some users
}
```

Vapor `Future` wrapped function return method

```Swift
func getAllUsers() -> Future<[User]> {
  // return some users at some point in the future.
}
```

## Working with an Unwrapping Futures

There are a number of convenience methods for not dealing with Futures directly. There are many scenarios where waiting is required though.

**flatMap(to:)**: use when the promise closure returns a Future

**map(to:)**: use when the promise closure returns a type other than Future

```Swift
func getAllUsers() -> Future<[User]> {
  // return some users at some point in the future.
  // we need to return some future of Array<User>
  return database.getAllUsers().flatMap(to: HTTPStatus.self) { users in
    return users
  }
}
```

## Transforms

Sometimes we don't care about the completion of a `Future`. This is a great example to use `transform(to:)`

```Swift
return database
       .getAllUsers()
       .flatMap(to: HTTPStatus.self) { users in
  let user = users[0]
  user.name = "Bob"
  return user.save().transform(to: HTTPStatus.noContent)
```

In the above example we return a Future promise to resolve an HTTPStatus. We save the user and finally `transform` the completed value into an HTTPStatus.noContent.

using `.transform` does **not** unwrap the result of the `user.save()` command.

## Flatten

Whenever you want to wait for multiple promises / futures to complete but you don't care of the returned result, use `.flatten(on:)`

```Swift
static func save(_ users: [User], request: Request) -> Future<HTTPStatus> {
  // 1
  var userSaveResults: [Future<User>] = []
  // 2
  for user in users {
    userSaveResults.append(user.save())
  }
  // 3
  return userSaveResults.flatten(on: request)
  // 4
  .transform(to: HTTPStatus.created)
}
```

1. define an array of `Future` objects that are the return type of the `.save()` operation. In this case its `User`

2. loop through each user appending the return value of user.save() to the array

3. use `flatten(on:)` to wait on all the futures to complete. This function requires a `Worker`.

4. Return a 201 Created status using the .transform function

**flatten(on:)**: waits for all the futures to return as they're executed async by the same Worker.

**Worker**: The thread that performs the work.

## Multiple Futures

If you need to wait on multiple futures of different types that don't rely on one another, you can use `flatMap(to: <#T##Result.Type#>, <#T##futureA: EventLoopFuture<A>##EventLoopFuture<A>#>, <#T##futureB: EventLoopFuture<B>##EventLoopFuture<B>#>, <#T##futureC: EventLoopFuture<C>##EventLoopFuture<C>#>, <#T##futureD: EventLoopFuture<D>##EventLoopFuture<D>#>, <#T##futureE: EventLoopFuture<E>##EventLoopFuture<E>#>, <#T##callback: (A, B, C, D, E) throws -> (EventLoopFuture<Result>)##(A, B, C, D, E) throws -> (EventLoopFuture<Result>)#>)`

Note that you can only support of to 5 different types of Futures at once.

This might look like the following

```Swift
flatMap(
  to: HTTPStatus.self,
  // A
  database.getAllUsers(),
  // B
  request.content.decode(UserData.self)) {
    // A      // B
    allUsers, userData in

    return allUsers[0].syncAddData(userData).transform(to: HTTPStatus.noContent)
  }
)
```

Also note that this `flatMap` is the global flat map operation. This example code completes 2 futures that are unrelated
