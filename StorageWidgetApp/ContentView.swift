import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Storage Widget App")
                .font(.largeTitle)
                .padding()
            
            Text("Check your widgets to see storage information")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

