import SwiftUI

@main
struct TaskManagerApp: App {
    init() {
        _ = DBManager.shared
    }

    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
    }
}
