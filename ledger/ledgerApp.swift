//
//  ledgerApp.swift
//  ledger
//
//  Created by Chris McElroy on 11/5/22.
//

import SwiftUI

@main
struct ledgerApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.ignoresSafeArea()
		}
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		if let window = NSApplication.shared.windows.first {
			window.titleVisibility = .hidden
			window.titlebarAppearsTransparent = true
			window.titlebarSeparatorStyle = .none
		}
		
		return
	}
}
