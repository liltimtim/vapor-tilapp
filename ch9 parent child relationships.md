# Parent Child Relationships

**Parent-child relationships**: describe a relationship where one model has "ownership" of one or more models. Known as **one-to-one** or **one-to-many**.

If modifying the database, for now we just wipe it and recreate it.

```bash
# 1
docker stop postgres
# 2
docker rm postgres
# 3
docker run --name postgres -e POSTGRES_DB=vapor \
  -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
  -p 5432:5432 -d postgres
```

Simply adding an ID pointer will add a Parent Child relationship

```Swift
struct ExampleObject: Codable {
  var id: Int?
  var someOtherID: SomeOther.ID // <-- Creates the relationship
}
```

`**Don't forget to add the object to migrations**`

## Querying Relationship

In our app, `User` and `Acronym` are now linked with a parent child relationship. The relationship is such that an Acronym is the parent of a user. It is a many-to-one relationship because only one acronym can be owned by a user but a user can have multiple acronyms.

Until implemented, its not possible to query on a Parent-child relationship

This is accomplished with Fluent

```Swift
extension Acronym {
  // 1
  var user: Parent<Acronym, User> {
    // 2
    return parent(\Acronym.userID)
  }
}
```

1. Add a computed property to Acronym to get the User object of thee acronym's owner.

2. Use Fluent's parent(\_ :) function to get the parent.

We can then write an endpoint like this...

```Swift
func getUserHandler(_ r: Request) throws -> Future<User> {
  return try r.parameters.next(Acronym.self)
    .flatMap(to: User.self) { acronym in
    // 1
      acronym.user.get(on: r)
    }
}
```

1. Use the new computed property created above to get the acronym's owner

### Getting the children

To get children, follow a similar pattern by adding a computed property on the child. In this case its the `User` object.

```Swift
extension User {
  var acronyms: Children<User, Acronym> {
    // 1
    return children(\.userID)
  }
}
```

1. The computed property uses Fluent's `children(_:)` function to get the children which takes in the keypath of the user reference on the acronym object.

### Foreign Key Constraints

**Foreign key constraints** describe a link between two tables. Frequently used for validation.

Pros of using foreign keys:

- ensures you cannot create acronyms with users that don't exist.
- cannot delete users until you've deleted all their acronyms
- cannot delete the user table until you've deleted the acronym table

Foreign keys are setup during a migration step.

To make the database aware of the relationship...

```Swift
// 1
extension Acronym: Migration {
  // 2
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    // 3
    return Database.create(self, on: connection) { builder in
    // 4
      try addProperties(to: builder)
      // 5
      builder.reference(from: \Acronym.userID, to: \User.id)
    }
  }
}
```

1. conform to migration

2. implement `prepare(on:)` required by Migration override the extension behavior / the default.

3. create table Acronym in the database

4. use `addProperties(to:)` to add all fields

5. add a ref between the userID property on `Acronym` and the id property on `User`. This sets of the foreign key constraint on the two tables.

** Note ** that because there is a link between an Acronym and User properties, the parent object `User` must be created BEFORE the child object Acronym.

This is done during the migration phase

```Swift
migrations.add(model: User.self, database: .psql)
migrations.add(model: Acronym.self, database: .psql)
```
