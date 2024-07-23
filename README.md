# SQLite Database with SwiftUI: Documentation

This documentation will guide you through the codebase for a simple SwiftUI application that demonstrates how to implement SQLite database operations (CRUD - Create, Read, Update, Delete) in SwiftUI. The project consists of the following files:

1. `DatabaseManager.swift`: Manages SQLite database operations.
2. `ContentView.swift`: Main SwiftUI view for the application.
3. `TestingAppApp.swift`: Application entry point.
4. `CrudOps.swift`: ViewModel for handling business logic and interacting with the database.
5. `Person.swift`: Model representing a person.

## Project Structure

### DatabaseManager.swift

`DatabaseManager` is a singleton class responsible for managing the SQLite database.

#### Key Components:

1. **Properties**:
   - `db`: Represents the connection to the SQLite database.
   - `persons`: A table object for the "persons" table.
   - `id`, `name`, `age`: Columns in the "persons" table.

2. **Initialization**:
   - The database connection is established, and the table is created if it doesn't exist.

3. **Methods**:
   - `createTable()`: Creates the "persons" table.
   - `addPerson(name: String, age: Int)`: Inserts a new person into the table.
   - `getAllPersons()`: Retrieves all persons from the table.
   - `deletePerson(personId: Int64)`: Deletes a person from the table by ID.

```swift
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
```

### ContentView.swift

`ContentView` is the main SwiftUI view that interacts with the user.

#### Key Components:

1. **State Variables**:
   - `name`, `age`: Used to capture user input for adding a new person.
   - `viewModel`: An instance of `PersonViewModel` to manage the data.

2. **UI Elements**:
   - A form for inputting name and age.
   - A list to display all persons in the database.
   - A button to add a new person.

3. **Methods**:
   - `delete(at:)`: Deletes a person from the list.

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PersonViewModel()
    @State private var name = ""
    @State private var age = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add New Person")) {
                        TextField("Name", text: $name)
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        Button(action: {
                            if let ageInt = Int(age) {
                                viewModel.addPerson(name: name, age: ageInt)
                                name = ""
                                age = ""
                            }
                        }) {
                            Text("Add Person")
                        }
                    }

                    Section {
                        List {
                            ForEach(viewModel.persons) { person in
                                VStack(alignment: .leading) {
                                    Text(person.name)
                                        .font(.headline)
                                    Text("Age: \(person.age)")
                                        .font(.subheadline)
                                }
                            }
                            .onDelete(perform: delete)
                        }
                    }
                }
                .navigationBarTitle("Persons")
                .onAppear {
                    viewModel.fetchPersons()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let person = viewModel.persons[index]
            viewModel.deletePerson(personId: person.id)
        }
    }
}
```

### TestingAppApp.swift

`TestingAppApp` is the entry point of the SwiftUI application.

```swift
import SwiftUI

@main
struct SQLiteDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### CrudOps.swift

`PersonViewModel` is an ObservableObject that acts as the ViewModel in the MVVM pattern, interacting with `DatabaseManager` to perform CRUD operations.

#### Key Components:

1. **Properties**:
   - `persons`: A published array of `Person` objects to be displayed in the view.

2. **Methods**:
   - `fetchPersons()`: Fetches all persons from the database.
   - `addPerson(name:age:)`: Adds a new person to the database.
   - `deletePerson(personId:)`: Deletes a person from the database.

```swift
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
```

### Person.swift

`Person` is a simple model representing a person with an ID, name, and age.

```swift
import Foundation

struct Person: Identifiable {
    var id: Int64
    var name: String
    var age: Int
}
```

## Implementation Steps

1. **Set Up SQLite**:
   - Add the SQLite.swift package to your project via Swift Package Manager.
   - Import SQLite in your `DatabaseManager.swift`.

2. **Create DatabaseManager**:
   - Define the `DatabaseManager` class as a singleton.
   - Establish a connection to the SQLite database.
   - Create the `persons` table with columns for `id`, `name`, and `age`.
   - Implement methods to add, fetch, and delete persons.

3. **Build PersonViewModel**:
   - Define the `PersonViewModel` class as an `ObservableObject`.
   - Implement methods to fetch all persons, add a new person, and delete a person.

4. **Design ContentView**:
   - Create a SwiftUI view with a form for inputting person details.
   - Use a list to display all persons.
   - Implement a delete action for removing persons from the list.

5. **Define Person Model**:
   - Create a simple struct `Person` to represent a person entity.

6. **Entry Point**:
   - Define the main entry point of the app in `TestingAppApp`.

By following these steps, you can create a SwiftUI application that interacts with an SQLite database to perform basic CRUD operations. This example covers the core aspects of integrating SQLite with SwiftUI, providing a solid foundation for more complex applications.
