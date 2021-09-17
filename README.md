<p align="center">
  <img src="https://github.com/fnc12/sqlite-orm-swift/blob/master/logo.png" alt="Sublime's custom image" width="600"/>
</p>

# SQLiteORM for Swift

![example workflow](https://github.com/fnc12/sqlite-orm-swift/actions/workflows/swift.yml/badge.svg)

SQLiteOrm-Swift is an ORM library for SQLite3 built with Swift 5

# Advantages

* **No raw string queries**
* **Intuitive syntax**
* **Comfortable interface - one call per single query**
* **CRUD support**
* **Does not depend on `Codable` protocol**
* **The only dependency** - SQLite3
* **In memory database support** - provide `:memory:` or empty filename

`SQLiteOrm` library allows to create easy data model mappings to your database schema. It is built to manage (CRUD) objects with a primary key and without it. It also allows you to specify table names and column names explicitly no matter how your classes actually named. And it does not depend on `Codable` protocol. Take a look at example:

```swift
import SQLiteORM

struct User : Initializable {
    var id = 0
    var firstName = ""
    var lastName = ""
    var birthDate = ""
    var imageUrl: String?
    var typeId = 0
}

struct UserType: Initializable {
    var id = 0
    var name = ""
}
```

So we have database with predefined schema like 

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY NOT NULL, 
    first_name TEXT NOT NULL, 
    last_name TEXT NOT NULL, 
    birth_date INTEGER NOT NULL, 
    image_url TEXT, 
    type_id INTEGER NOT NULL)
    
CREATE TABLE user_types (
    id INTEGER PRIMARY KEY NOT NULL, 
    name TEXT NOT NULL)
```

Now we tell `SQLiteOrm` library about our schema and provide database filename. We create `storage` helper object that has CRUD interface. Also we create every table and every column. All code is intuitive and minimalistic.

```swift
let path = getDocumentsDirectory() + "/db.sqlite"
do {
    let storage = try Storage(filename: path,
                              tables:
                                Table<User>(name: "users",
                                            columns:
                                               Column(name: "id", keyPath: \User.id, constraints: primaryKey(), notNull()),
                                               Column(name: "first_name", keyPath: \User.firstName, constraints: notNull()),
                                               Column(name: "last_name", keyPath: \User.lastName, constraints: notNull()),
                                               Column(name: "birth_date", keyPath: \User.birthDate, constraints: notNull()),
                                               Column(name: "image_url", keyPath: \User.imageUrl),
                                               Column(name: "type_id", keyPath: \User.typeId, constraints: notNull())),
                                Table<UserType>(name: "user_types",
                                                columns:
                                                    Column(name: "id", keyPath: \UserType.id, constraints: primaryKey(), notNull()),
                                                    Column(name: "name", keyPath: \UserType.name, constraints: notNull())))
}catch{
    print("error happened \(error)")
}
```

Too easy isn't it? To create a column you have to pass two arguments at least: its name in the table and your mapped class keypath. You can also add extra arguments to tell your storage about column's constraints like `primaryKey()`, `notNull()`, `unique()`.

# CRUD

Let's create and insert new `User` into our database. First we need to create a `User` object with any id and call `insert` function. It will return id of just created user or throw exception if something goes wrong. If you want to insert a user with id you specified then you need to use `replace` function instead of `insert`.

```swift
var user = User(id: 0, firstName: "John", lastName: "Doe", birthDate: 664416000, imageUrl: "url_to_heaven", typeId: 3)
let insertedId = try storage.insert(object: user)
print("insertedId = \(insertedId)")
user.id = Int(insertedId)

let secondUser = User(id: 2, firstName: "Alice", lastName: "Inwonder", birthDate: 831168000, imageUrl: nil, typeId: 2)
try storage.replace(object: secondUser) //  insert with 'id' 2
```

Next let's get our user by id.

```swift
if let user1: User = try storage.get(id: 1) {
    print("user = \(user1.firstName) \(user1.lastName)")
}else{
    print("user with id 1 does not exist")
}
```

We can also update our user. Storage updates row by id provided in `user` object and sets all other non `primary_key` fields to values stored in the passed `user` object. So you can just assign fields to `user` object you want and call `update`:

```swift
user.firstName = "Nicholas"
user.imageUrl = "https://cdn1.iconfinder.com/data/icons/man-icon-set/100/man_icon-21-512.png"
try storage.update(object: user)
```

And delete. To delete you have to pass a whole object.

```swift
try storage.delete(object: user)
```

Also we can extract all objects into `Array`:

```swift
let allUsers: [User] = try storage.getAll()
print("allUsers (\(allUsers.count):")
for user in allUsers {
    print(user)
}
```

# Migrations functionality

There are no explicit `up` and `down` functions that are used to be used in migrations. Instead `SQLiteORM` offers `syncSchema` function that takes responsibility of comparing actual db file schema with one you specified in `Storage` init call and if something is not equal it alters or drops/creates schema.

```swift
try storage.syncSchema(preserve: true)
```

Please beware that `syncSchema` doesn't guarantee that data will be saved. It *tries* to save it only. Below you can see rules list that `syncSchema` follows during call:
* if there are excess tables exist in db they are ignored (not dropped)
* every table from storage is compared with it's db analog and 
    * if table doesn't exist it is created
    * if table exists its colums are being compared with table_info from db and
        * if there are columns in db that do not exist in storage (excess) table will be dropped and recreated if `preserve` is `false`, and table will be copied into temporary table without excess columns, source table will be dropped, copied table will be renamed to source table (sqlite remove column technique) if `preserve` is `true`. Beware that setting it to `true` may take time for copying table rows.
        * if there are columns in storage that do not exist in db they will be added using 'ALTER TABLE ... ADD COLUMN ...' command and table data will not be dropped but if any of added columns is null but has not default value table will be dropped and recreated
        * if there is any column existing in both db and storage but differs by any of properties (pk, notnull) table will be dropped and recreated (dflt_value isn't checked cause there can be ambiguity in default values, please beware).

The best practice is to call this function right after storage creation.

# Notes

To work well your data model class must inherit from `Initializable` which required only `init()` with no arguments existance and must not have const fields mapped to database cause they are assigned during queries. Otherwise code won't compile.
