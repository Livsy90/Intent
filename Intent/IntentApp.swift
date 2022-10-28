//
//  IntentApp.swift
//  Intent
//
//  Created by Livsy on 28.10.2022.
//

import SwiftUI

@main
struct IntentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
