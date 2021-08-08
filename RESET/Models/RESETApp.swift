//
//  RESETApp.swift
//  RESET
//
//  Created by Wangyiwei on 2021/5/20.
//

import SwiftUI

@main
struct RESETApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
