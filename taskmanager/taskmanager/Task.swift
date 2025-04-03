//
//  Task.swift
//  taskmanager
//
//  Created by harsh saw on 2025-04-02.
//

import Foundation

struct Task: Identifiable {
    let id: Int64
    let title: String
    let description: String
    let isDone: Bool
}
