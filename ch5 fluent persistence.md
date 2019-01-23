# Fluent and Peristing Models

**Fluent**: Vapor's ORM (Object Relational Mapping) tool. Abstraction layer between the Vapor application and the database, and it's designed to make working with databases easier.

## Foundation: Acronyms App

From this chapter forward, the application (Today I Learned) will be used to demonstrait features.

1. vapor new TILApp

### Create Fluent Model

All fluent models must conform to `Codable`. Its also good practice to mark classes as `final` which provides performance benefits.

Fluent includes several protocols which must also be conformed to.

**Model**

```Swift
extension ClassName: Model {
  // 1
  typealias Database = SQLiteDatabase
  // 2
  typealias ID = Int
  // 3
  public static var idKey: IDKey = \Acronym.id
}
```

1. Tell Fluent what database to use for the this model. The template is already configured to use SQLite.

2. Tell Fluent what type the ID is.

3. Tell Fluent the key path of the model's ID property.

Fluent already provides ways to define these models though, so implementing the `Model` Protocol isn't required.

Instead, simply implement the `SQLiteModel` protocol.

```Swift
extension Acronym: SQLiteModel { }
```

### Fluent Migrations

In order to save anything in the database, Fluent must create tables for them. This is accomplished via **migrations**.

```Swift
extension Acronym: Migration { }
```

Fluent infers the schema for your model thanks to `Codable`. For basic models you can use the default Migration.

Once a model conforms to `Migration` protocol, it can be added to the datbase.

```Swift
migrations.add(model: Acronym.self, database: .sqlite)
```

You can also mix and match different types of databases. Models can save to different databases as well.

## Saving Models

Finally making the model conform to `Content` will wrap the Codable implementation and allow for easy saving.

```Swift
extension Acronym: Content { }
```
