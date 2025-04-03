import Foundation
import SQLite3

class DBManager {
    static let shared = DBManager()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTable()
    }

    // MARK: - Open Database
    func openDatabase() {
        let fileURL = try! FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("tasks.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ Failed to open database")
        } else {
            print("✅ Database opened at \(fileURL.path)")
        }
    }

    // MARK: - Create Table
    func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            is_done INTEGER DEFAULT 0
        );
        """
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("✅ Table created.")
            } else {
                print("❌ Could not create table.")
            }
        } else {
            print("❌ CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    // MARK: - Insert Task
    func addTask(title: String, description: String?) {
        let insertQuery = "INSERT INTO Tasks (title, description, is_done) VALUES (?, ?, 0);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, title, -1, nil)
            sqlite3_bind_text(stmt, 2, description ?? "", -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Task inserted.")
            } else {
                print("❌ Could not insert task.")
            }
        } else {
            print("❌ INSERT statement could not be prepared.")
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - Fetch All Tasks
    func getAllTasks() -> [Task] {
        let query = "SELECT * FROM Tasks;"
        var stmt: OpaquePointer?
        var tasks: [Task] = []

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int64(stmt, 0)
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let description = String(cString: sqlite3_column_text(stmt, 2))
                let isDone = sqlite3_column_int(stmt, 3) != 0

                tasks.append(Task(id: id, title: title, description: description, isDone: isDone))
            }
        } else {
            print("❌ SELECT statement could not be prepared")
        }

        sqlite3_finalize(stmt)
        return tasks
    }

    // MARK: - Toggle Done
    func toggleDone(taskId: Int64, newStatus: Bool) {
        let query = "UPDATE Tasks SET is_done = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, newStatus ? 1 : 0)
            sqlite3_bind_int64(stmt, 2, taskId)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Updated task status.")
            } else {
                print("❌ Could not update task.")
            }
        } else {
            print("❌ UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(stmt)
    }
}
