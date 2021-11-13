import Foundation
import SQLiteORM

struct Employee: Initializable {
    var id = 0
    var name = ""
    var age = 0
    var address = ""
    var salary = 0.0
}

let storage = try Storage(filename: "",
                          tables: Table<Employee>(name: "COMPANY",
                                                  columns: Column(name: "ID", keyPath: \Employee.id, constraints: primaryKey()),
                                                  Column(name: "NAME", keyPath: \Employee.name),
                                                  Column(name: "AGE", keyPath: \Employee.age),
                                                  Column(name: "ADDRESS", keyPath: \Employee.address),
                                                  Column(name: "SALARY", keyPath: \Employee.salary)))
try storage.syncSchema(preserve: false)
try storage.replace(Employee(id: 1, name: "Paul", age: 32, address: "California", salary: 20000.0))
try storage.replace(Employee(id: 2, name: "Allen", age: 25, address: "Texas", salary: 15000.0))
try storage.replace(Employee(id: 3, name: "Teddy", age: 23, address: "Norway", salary: 20000.0))
try storage.replace(Employee(id: 4, name: "Mark", age: 25, address: "Rich-Mond", salary: 65000.0))
try storage.replace(Employee(id: 5, name: "David", age: 27, address: "Texas", salary: 85000.0))
try storage.replace(Employee(id: 6, name: "Kim", age: 22, address: "South-Hall", salary: 45000.0))
try storage.replace(Employee(id: 7, name: "James", age: 24, address: "Houston", salary: 10000.0))

//  show 'COMPANY' table contents
for employee: Employee in try storage.getAll() {
    print("\(employee)")
}
print("")

//  'UPDATE COMPANY SET ADDRESS = 'Texas' WHERE ID = 6'
var employee6: Employee = try storage.get(id: 6)!
employee6.address = "Texas"
try storage.update(employee6)   //  actually this call updates all non-primary-key columns' values to passed object's fields

//  show 'COMPANY' table contents again
for employee: Employee in try storage.getAll() {
    print("\(employee)")
}
print("")

//  'UPDATE COMPANY SET ADDRESS = 'Texas', SALARY = 20000.00 WHERE AGE < 30'
try storage.update(all: Employee.self,
                   set(\Employee.address &= "Texas",
                        \Employee.salary &= 20000.00),
                   where_(\Employee.age < 30))

//  show 'COMPANY' table contents one more time
for employee in storage.iterate(all: Employee.self) {
    print("\(employee)")
}
print("")
