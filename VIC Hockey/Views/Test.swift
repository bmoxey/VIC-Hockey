import SwiftUI

struct Test: View {
    @State private var people = [
        Person(name: "John", games: 10, goals: 5, cards: 6),
        Person(name: "Alice", games: 8, goals: 3, cards: 0),
        Person(name: "Brett", games: 5, goals: 9, cards: 2),
        Person(name: "Paul", games: 11, goals: 0, cards: 3),
        Person(name: "Marty", games: 3, goals: 0, cards: 1),
        Person(name: "Janice", games: 14, goals: 1, cards: 0),
        // Add more people to the array as needed
    ]
    
    @State private var sortedByName = false
    @State private var sortedByValue: KeyPath<Person, Int>? = nil
    @State private var sortAscending = true
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Button(action: {
                        self.sortedByName.toggle()
                        self.sortedByValue = nil
                    }) {
                        Text("Name")
                            .frame(width: 120)
                            .background(sortedByName ? Color.yellow : Color.clear)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        self.sortedByValue = \Person.games
                        self.sortedByName = false
                        self.sortAscending.toggle()
                    }) {
                        Text("Games")
                            .frame(width: 50)
                            .background(sortedByValue == \Person.games ? Color.green : Color.clear)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        self.sortedByValue = \Person.goals
                        self.sortedByName = false
                        self.sortAscending.toggle()
                    }) {
                        Text("Goals")
                            .frame(width: 50)
                            .background(.pink)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        self.sortedByValue = \Person.cards
                        self.sortedByName = false
                        self.sortAscending.toggle()
                    }) {
                        Text("Cards")
                            .frame(width: 50)
                            .background(Color.cyan)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                ForEach(people.sorted(by: sortDescriptor), id: \.id) { person in
                    HStack {
                        Text(person.name)
                            .frame(width: 120, alignment: .leading)
                        Text("\(person.games)")
                            .frame(width: 60)
                        Text("\(person.goals)")
                            .frame(width: 60)
                        Text("\(person.cards)")
                            .frame(width: 60)
                    }
                }
            }
            
        }
    }
    
    private var sortDescriptor: (Person, Person) -> Bool {
        let ascending = sortAscending  // Capture sortAscending as a local variable
        if let sortedByValue = sortedByValue {
            return { (person1, person2) in
                if ascending {
                    return person1[keyPath: sortedByValue] < person2[keyPath: sortedByValue]
                } else {
                    return person1[keyPath: sortedByValue] > person2[keyPath: sortedByValue]
                }
            }
        } else if sortedByName {
            return { (person1, person2) in
                if ascending {
                    return person1.name < person2.name
                } else {
                    return person1.name > person2.name
                }
            }
        } else {
            // Default sorting order
            return { _, _ in true }
        }
    }

}

struct Person: Identifiable {
    var id = UUID()
    var name: String
    var games: Int
    var goals: Int
    var cards: Int
}

struct ContentView1_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
