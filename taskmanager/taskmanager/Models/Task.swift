import Foundation

struct Task: Identifiable {
    var id: Int64
    var title: String
    var description: String?
    var isDone: Bool
}
