import SwiftUI

struct AppView: View {
    var body: some View {
        VStack {
            Text("Correct Attempts: \(0)")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text("Wrong Attempts: \(0)")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Spacer()
            Text("Word1")
            Text("Word2")
            Spacer()
            HStack {
                Button("Correct") { }
                Button("Wrong") { }
            }
        }
        .padding()
    }
}

#Preview {
    AppView()
}
