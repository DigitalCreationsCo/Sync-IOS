//
//  messageflowApp.swift
//  messageflow
//
//  Created by Bryant's MBP on 5/23/24.
//

import SwiftUI

@main
struct messageflowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class RuleManager {
    static let shared = RuleManager()

    var rules: [Rule] = []

    func addRule(_ rule: Rule) {
        rules.append(rule)
    }

    func applyRules(to message: String, from sender: String) {
        for rule in rules {
            if rule.matches(message: message, sender: sender) {
                rule.apply(to: message, sender: sender)
            }
        }
    }
}

class Rule {
    var condition: (String, String) -> Bool
    var action: (String, String) -> Void

    init(condition: @escaping (String, String) -> Bool, action: @escaping (String, String) -> Void) {
        self.condition = condition
        self.action = action
    }

    func matches(message: String, sender: String) -> Bool {
        return condition(message, sender)
    }

    func apply(to message: String, sender: String) {
        action(message, sender)
    }
}
