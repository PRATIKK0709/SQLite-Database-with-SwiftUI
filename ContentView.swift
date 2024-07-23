//
//  ContentView.swift
//  TestingApp
//
//  Created by Pratik Ray on 22/07/24.
//
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


