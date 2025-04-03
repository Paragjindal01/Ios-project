import SwiftUI

struct AddTaskView: View {
    @State private var title = ""
    @State private var description = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Task Title", text: $title)
                TextField("Description", text: $description)

                Button("Add Task") {
                    guard !title.isEmpty else { return }
                    DBManager.shared.addTask(title: title, description: description)
                    title = ""
                    description = ""
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Add Task")
        }
    }
}
