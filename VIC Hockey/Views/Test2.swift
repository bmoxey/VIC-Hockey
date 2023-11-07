import SwiftUI

struct Test2: View {
    var body: some View {
        List {
            ForEach(0..<10, id: \.self) { index in
                Text("Row \(index)")
                    .listRowSeparatorTint(index == 3 ? Color("AccentColor") : Color(UIColor.separator)) // Change color based on row index
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Test2()
    }
}
