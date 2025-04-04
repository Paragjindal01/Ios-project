import SwiftUI

struct AddTaskView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var buttonColor = Color.blue
    
    // Random colors for buttons
    private let buttonColors: [Color] = [
        .blue, .purple, .green, .teal, .indigo
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                        .disabled(isSubmitting)
                    
                    TextField("Description (Optional)", text: $description)
                        .disabled(isSubmitting)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button(action: submitTask) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Add Task")
                                    .bold()
                            }
                        }
                        .padding()
                        .frame(minWidth: 150)
                        .background(title.isEmpty ? Color.gray : buttonColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(title.isEmpty || isSubmitting)
                        Spacer()
                    }
                    .listRowBackground(Color(.systemBackground))
                }
            }
            .navigationTitle("Add Task")
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay(
                // Success message overlay
                Group {
                    if showSuccess {
                        VStack {
                            Spacer()
                            Text("Task Added Successfully!")
                                .font(.headline)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                .padding(.bottom, 20)
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut(duration: 0.3), value: showSuccess)
                    }
                }
            )
            .onAppear {
                // Set a random color for the button
                buttonColor = buttonColors.randomElement() ?? .blue
            }
        }
    }
    
    private func submitTask() {
        guard !title.isEmpty else { return }
        
        isSubmitting = true
        
        APIService.shared.addTask(title: title, description: description) { task, error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let error = error {
                    errorMessage = "Failed to add task: \(error.localizedDescription)"
                    showError = true
                } else if task != nil {
                    // Show success message
                    withAnimation {
                        showSuccess = true
                    }
                    
                    // Clear the form
                    title = ""
                    description = ""
                    
                    // Change button color
                    buttonColor = buttonColors.randomElement() ?? .blue
                    
                    // Hide success message after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccess = false
                        }
                    }
                }
            }
        }
    }
}
