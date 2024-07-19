//
//  certmgrApp.swift
//  certmgr
//
//  Created by Alfred Eisenberg on 7/16/24.
//

import SwiftUI

@main
struct certmgrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
