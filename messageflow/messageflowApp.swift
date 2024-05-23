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
