//
//  ContentView.swift
//  ledger
//
//  Created by Chris McElroy on 11/5/22.
//

import SwiftUI

enum Tab: Int {
	case importing, sort, summary, ledger
}

struct ContentView: View {
	@State var currentTab: Tab = .importing
	
    var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 65) {
				Spacer()
				TabView(name: "import", type: .importing, currentTab: $currentTab)
				TabView(name: "sort", type: .sort, currentTab: $currentTab)
				TabView(name: "summary", type: .summary, currentTab: $currentTab)
				TabView(name: "ledger", type: .ledger, currentTab: $currentTab)
				Spacer()
			}
			.font(.headline)
			.padding(.all, 20)
			.background(KeyEventHandling(tab: { self.currentTab = Tab(rawValue: self.currentTab.rawValue + 1) ?? .importing }))
			.layoutPriority(10)
			if currentTab == .importing {
				ImportView()
			} else if currentTab == .sort {
				SortView()
			} else if currentTab == .summary {
				SummaryView()
			} else {
				LedgerView()
			}
		}
//		.onAppear {
//			Storage.set(nil, for: .files)
//			Storage.set(nil, for: .transactions)
//			Storage.main.files = [:]
//			Storage.main.transactions = [:]
//		}
    }
}

struct TabView: View {
	let name: String
	let type: Tab
	@Binding var currentTab: Tab
	
	var body: some View {
		Text(name)
			.underline(currentTab == type)
			.onTapGesture { currentTab = type }
			.fixedSize()
	}

}
