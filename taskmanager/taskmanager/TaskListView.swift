import SwiftUI

struct TaskListView: View {
    @State private var tasks: [Task] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title).font(.headline)
                            Text(task.description).font(.subheadline).foregroundColor(.gray)
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
            .navigationTitle("Tasks")
            .onAppear {
                refreshTasks()
            }
        }
    }

    func refreshTasks() {
        tasks = DBManager.shared.getAllTasks()
    }
}
