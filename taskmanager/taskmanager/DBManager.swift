//
//  DBManager.swift
//  taskmanager
//
//  Created by harsh saw on 2025-04-02.
//

import Foundation
import SQLite3

class DBManager {
    static let shared = DBManager()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTable()
    }

    func openDatabase() {
        let fileURL = try! FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("tasks.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ Failed to open database")
        } else {
            print("✅ DB opened at \(fileURL.path)")
        }
    }

    func createTable() {
        let query = """
        CREATE TABLE IF NOT EXISTS Tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            is_done INTEGER DEFAULT 0
        );
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Table created")
            }
        }
        sqlite3_finalize(stmt)
    }

    func addTask(title: String, description: String?) {
        let query = "INSERT INTO Tasks (title, description, is_done) VALUES (?, ?, 0);"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, query, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, title, -1, nil)
        sqlite3_bind_text(stmt, 2, description ?? "", -1, nil)
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("✅ Task inserted")
        }
        sqlite3_finalize(stmt)
    }

    func getAllTasks() -> [Task] {
        var result: [Task] = []
        let query = "SELECT * FROM Tasks;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int64(stmt, 0)
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let desc = String(cString: sqlite3_column_text(stmt, 2))
                let isDone = sqlite3_column_int(stmt, 3) == 1
                result.append(Task(id: id, title: title, description: desc, isDone: isDone))
            }
        }
        sqlite3_finalize(stmt)
        return result
    }

    func toggleDone(taskId: Int64, newStatus: Bool) {
        let query = "UPDATE Tasks SET is_done = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, query, -1, &stmt, nil)
        sqlite3_bind_int(stmt, 1, newStatus ? 1 : 0)
        sqlite3_bind_int64(stmt, 2, taskId)
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("✅ Status updated")
        }
        sqlite3_finalize(stmt)
    }
}
