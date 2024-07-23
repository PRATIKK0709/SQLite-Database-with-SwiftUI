//
//  CrudOps.swift
//  TestingApp
//
//  Created by Pratik Ray on 23/07/24.
//

import SwiftUI

class PersonViewModel: ObservableObject {
    @Published var persons = [Person]()
    
    func fetchPersons() {
        persons = DatabaseManager.shared.getAllPersons()
    }
    
    func addPerson(name: String, age: Int) {
        let _ = DatabaseManager.shared.addPerson(name: name, age: age)
        fetchPersons()
    }
    
    func deletePerson(personId: Int64) {
        DatabaseManager.shared.deletePerson(personId: personId)
        fetchPersons()
    }
}
