import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("📱 Task Manager App")
                    .font(.title)
                    .bold()

                Text("🧑‍🎓 Developed for CS316 project.")
                Text("🧠 Built using SwiftUI 5 + SQLite")
                Text("📅 April 2025")

                Spacer()
            }
            .padding()
            .navigationTitle("About")
        }
    }
}
