//
//  DatabaseManager.swift
//  TestingApp
//
//  Created by Pratik Ray on 22/07/24.
//

import SQLite
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    private let db: Connection?
    private let persons = Table("persons")
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let age = Expression<Int>("age")

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
            createTable()
        } catch {
            db = nil
            print("Unable to open database. Error: \(error)")
        }
    }
    
    private func createTable() {
        do {
            try db?.run(persons.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(name)
                table.column(age)
            })
        } catch {
            print("Unable to create table. Error: \(error)")
        }
    }
    
    func addPerson(name: String, age: Int) -> Int64? {
        do {
            let insert = persons.insert(self.name <- name, self.age <- age)
            let id = try db?.run(insert)
            return id
        } catch {
            print("Insert failed. Error: \(error)")
            return nil
        }
    }
    
    func getAllPersons() -> [Person] {
        var personsList = [Person]()
        
        do {
            for person in try db!.prepare(persons) {
                let person = Person(id: person[id], name: person[name], age: person[age])
                personsList.append(person)
            }
        } catch {
            print("Select failed. Error: \(error)")
        }
        
        return personsList
    }
    
    func deletePerson(personId: Int64) {
        do {
            let person = persons.filter(id == personId)
            try db?.run(person.delete())
        } catch {
            print("Delete failed. Error: \(error)")
        }
    }
}
