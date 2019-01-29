# Sibling Relationships

**sibling relationships**: describe a relationship that links two models to each other. They are also known as **many-to-many** relationships. Unlike parent-child relationships, there are no constraints between models.

As an example, if you had a `Toy` object and a `Dog` object, their relationship could be that a dog can play with many toys and a toy can be played with by many dogs however they can independently exist without the other.

### Creating a pivot

**Pivot**: Fluent provides a way to model many-to-many relationships efficiently.

A Pivot is a Fluent model which contains a linking relationship between two entities.

```Swift
import FluentPostgreSQL
import Foundation
// 1
final class AcronymCategoryPivot: PostgreSQLUUIDPivot, ModifiablePivot {
  // 2
  var id: UUID?
  // 3
  var acronymID: Acronym.ID
  var categoryID: Category.ID

  // 4
  typealias Left = Acronym
  typealias Right = Category
  // 5
  static let leftIDKey: LeftIDKey = \.acronymID
  static let rightIDKey: RightIDKey = \.categoryID

  // 6
  init(_ acronym: Acronym, _ category: Category) throws {
    self.acronymID = try acronym.requireID()
    self.categoryID = try category.requireID()
  }
}

extension AcronymCategoryPivot: Migration { }
```

1. dfeine a new object that conforms to `PostgreSQLUUIDPivot`. `ModifiablPivot` allows to use syntactic sugar Vapor provides for adding and remove relationships.

2. Define an id for the model in this case its a `UUID`

3. define two properties to link to the IDs of Acronym and Category. This is the holder of the relationship

4. define the `Left` and `Rgith` types required by Pivot. Tells Fluent what thee two models in the relationship are

5. Tell fluent the key path of the two ID props for each side of the relationship

6. Implement the throwing init as required by `ModifiablePivot`.

7. Conform to Migration to allow fluent to setup the table.

### Add Pivot to Model

To actually creeate a relationship between twomodels, use the pivot. Fluent provides convenience methods to help create and remove the relationships.

**Acronym.swift file**

```Swift
extension Acronym {
  // Syntax
  // var categories: Siblings<LEFT, RIGHT, MODEL_HOLDING_PIVOT> { }
  var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
    return siblings()
  }
}
```

- We define a computed property called `categories` which uses Fluent's helper methods. In this case, we are using a helper method to return the relationship between acronym and category.

**Inside our Acronym Controller**

```Swift
func addCategoriesHandler(_ r: Request) throws -> Future<HTTPStatus> {
  return flatMapt(
    to: HTTPStatus.self,
    r.parameters.next(Acronym.self),
    r.parameters.next(Category.self)
  ) { acronym, category in
    return acronym.categories.attach(category, on: r).transform(to: .created)
  }
}
```

### Query the Relationship

**Acronym Controller**

```Swift
// define a route to handle querying the relationship
func getCategoriesHandler(_ r: Request) throws -> Future<[Category]> {
  return try r.parameters.next(Acronym.self).flatMap(to: [Category].self) { acronym in
    // use the computeed categories query to retrieve all the relationships
    try acronym.categories.query(on: r).all()
  }
}
```

### Removing Relationships

**Acronym Controller**

```Swift
func removeCategoriesHandler(_ r: Request) throws -> Future<HTTPStatus> {
  return try flatMap(
    to: HTTPStatus.self,
    r.parameters.next(Acronym.self),
    r.parameters.next(Category.self)) { a, c in
      return a.categories.detach(c, on: r)
        .transform(to: .noContent)
    }
  )
}
```
