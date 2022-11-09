//
//  ContentView.swift
//  ledger
//
//  Created by Chris McElroy on 11/5/22.
//

import SwiftUI

enum Tab {
	case importing, sort, summary, ledger
}

struct ContentView: View {
	@State var currentTab: Tab = .importing
	
    var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 65) {
				Text("import").underline(currentTab == .importing)
				Text("sort")
				Text("summary")
				Text("ledger")
			}
			.font(.headline)
			.padding(.all, 20)
			DropTab()
				.frame(minWidth: 500, idealWidth: 600, minHeight: 400, idealHeight: 500)
		}
    }
}
