import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Tasks")
                }

            AddTaskView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add Task")
                }

            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("About")
                }
        }
        .accentColor(.blue) 
    }
}
