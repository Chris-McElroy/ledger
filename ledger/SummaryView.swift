//
//  SummaryView.swift
//  ledger
//
//  Created by Chris McElroy on 11/23/22.
//

import SwiftUI

struct SummaryView: View {
	let categories = [
		CategorySummary(id: .sweeps, year: 2022),
		CategorySummary(id: .income, year: 2022),
		CategorySummary(id: .utilities, year: 2022),
		CategorySummary(id: .medical, year: 2022),
		CategorySummary(id: .groceries, year: 2022),
		CategorySummary(id: .car, year: 2022),
		CategorySummary(id: .haircut, year: 2022),
		CategorySummary(id: .software, year: 2022),
		CategorySummary(id: .goods, year: 2022),
		CategorySummary(id: .dining, year: 2022),
		CategorySummary(id: .exercise, year: 2022),
		CategorySummary(id: .vacation, year: 2022),
		CategorySummary(id: .gifts, year: 2022),
		CategorySummary(id: .games, year: 2022),
		CategorySummary(id: .school, year: 2022),
		CategorySummary(id: .climate, year: 2022),
		CategorySummary(id: .politics, year: 2022),
		CategorySummary(id: .patreon, year: 2022)
	]
	
	static let monthNames = ["null", "january", "februrary", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
	
	var body: some View {
		VStack {
			Table(categories) {
			 Group {
				 TableColumn("category", value: \CategorySummary.id.rawValue).width(100)
				 TableColumn("january", value: \CategorySummary.january).width(80)
				 TableColumn("february", value: \CategorySummary.february).width(80)
				 TableColumn("march", value: \CategorySummary.march).width(80)
				 TableColumn("april", value: \CategorySummary.april).width(80)
				 TableColumn("may", value: \CategorySummary.may).width(80)
				 TableColumn("june", value: \CategorySummary.june).width(80)
			 }
			 Group {
				 TableColumn("july", value: \CategorySummary.july).width(80)
				 TableColumn("august", value: \CategorySummary.august).width(80)
				 TableColumn("september", value: \CategorySummary.september).width(80)
				 TableColumn("october", value: \CategorySummary.october).width(80)
				 TableColumn("november", value: \CategorySummary.november).width(80)
				 TableColumn("december", value: \CategorySummary.december).width(80)
			 }
		 }
		}
	}
}

struct CategorySummary: Identifiable {
	let id: MyCategory
	var year: Int
	
	var january: String { getMonthSummary(for: 1) }
	var february: String { getMonthSummary(for: 2) }
	var march: String { getMonthSummary(for: 3) }
	var april: String { getMonthSummary(for: 4) }
	var may: String { getMonthSummary(for: 5) }
	var june: String { getMonthSummary(for: 6) }
	var july: String { getMonthSummary(for: 7) }
	var august: String { getMonthSummary(for: 8) }
	var september: String { getMonthSummary(for: 9) }
	var october: String { getMonthSummary(for: 10) }
	var november: String { getMonthSummary(for: 11) }
	var december: String { getMonthSummary(for: 12) }
	
	func getMonthSummary(for month: Int) -> String {
		let transactions = Storage.main.transactions.values.filter({ $0.myCategory == id }).filter({ Calendar.current.date($0.date, matchesComponents: DateComponents(year: year, month: month)) })
		return priceToString(transactions.reduce(0, { $0 + $1.total }), currency: "USD")
	}
}
