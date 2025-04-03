import SwiftUI

struct TaskListView: View {
    @State private var tasks: [Task] = []
    @State private var newTitle = ""
    @State private var newDesc = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(tasks) { task in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.headline)
                                if let desc = task.description {
                                    Text(desc)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isDone ? .green : .gray)
                                .onTapGesture {
                                    DBManager.shared.toggleDone(taskId: task.id, newStatus: !task.isDone)
                                    refreshTasks()
                                }
                        }
                    }
                }

                Divider()
                VStack(spacing: 10) {
                    TextField("New Task Title", text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Optional Description", text: $newDesc)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Add Task") {
                        guard !newTitle.isEmpty else { return }
                        DBManager.shared.addTask(title: newTitle, description: newDesc.isEmpty ? nil : newDesc)
                        newTitle = ""
                        newDesc = ""
                        refreshTasks()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Task Manager")
        }
        .onAppear {
            refreshTasks()
        }
    }

    private func refreshTasks() {
        tasks = DBManager.shared.getAllTasks()
    }
}
