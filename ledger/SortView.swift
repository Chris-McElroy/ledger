//
//  SortView.swift
//  ledger
//
//  Created by Chris McElroy on 11/22/22.
//

import SwiftUI

enum SortOption {
	case date, file
}

struct SortView: View {
	@ObservedObject var storage: Storage = Storage.main
	@State var transaction: Transaction? = nil
	@State var sortBy: SortOption = .date
	
	var body: some View {
		VStack(spacing: 0) {
			// add this back in if i want to sort again
//			Text("sort by")
//			Spacer().frame(height: 10)
//			HStack(spacing: 20) {
//				Text("date")
//				Text("file")
//			}
//			Spacer().frame(height: 20)
			if let transaction {
				VStack {
					Text("date: " + transaction.date.formatted(date: .long, time: .omitted))
					Text("amount: " + priceToString(transaction.amount))
					if let merchant = transaction.merchant {
						Text("merchant: " + merchant)
					}
					if let description = transaction.description {
						Text("description:\n" + description)
					}
					if let ref = transaction.ref {
						Text("reference: " + ref)
					}
					if let notes = transaction.notes {
						Text("notes:\n" + notes)
					}
				}
				.multilineTextAlignment(.center)
				Spacer()
				Spacer()
				Spacer()
				Spacer()
				Spacer()
				Spacer()
				Spacer()
				Spacer()
				HStack(alignment: .top, spacing: 20) {
					VStack(spacing: 10) {
						SortButton(type: .sweeps, sort: sort)
						SortButton(type: .income, sort: sort)
						Spacer()
					}
					VStack(spacing: 10) {
						SortButton(type: .utilities, sort: sort)
						SortButton(type: .medical, sort: sort)
						SortButton(type: .groceries, sort: sort)
						SortButton(type: .car, sort: sort)
						SortButton(type: .haircut, sort: sort)
						SortButton(type: .software, sort: sort)
						Spacer()
					}
					VStack(spacing: 10) {
						SortButton(type: .goods, sort: sort)
						SortButton(type: .dining, sort: sort)
						SortButton(type: .exercise, sort: sort)
						SortButton(type: .vacation, sort: sort)
						SortButton(type: .gifts, sort: sort)
						SortButton(type: .games, sort: sort)
						SortButton(type: .school, sort: sort)
						Spacer()
					}
					VStack(spacing: 10) {
						SortButton(type: .climate, sort: sort)
						SortButton(type: .politics, sort: sort)
						SortButton(type: .patreon, sort: sort)
						Spacer()
					}
				}
			} else {
				Spacer()
			}
		}
		.padding(.all, 20)
		.background(.black)
		.onAppear {
			transaction = storage.transactions.filter({ $0.value.myCategory == nil }).sorted(by: { $0.value.date < $1.value.date }).first?.value
		}
	}
	
	func sort(into category: MyCategory) {
		guard let transaction else { print("error — sorted with no transaction?"); return }
		transaction.myCategory = category
		storage.files[transaction.file]?.sortedTransactions.append(transaction.id)
		Storage.set(storage.transactions.map { $0.value.toDict() }, for: .transactions)
		Storage.set(storage.files.map { $0.value.toDict() }, for: .files)
		self.transaction = storage.transactions.filter({ $0.value.myCategory == nil }).sorted(by: { $0.value.date < $1.value.date }).first?.value
	}
	
	struct SortButton: View {
		let type: MyCategory
		let sort: (MyCategory) -> Void
		@State var underline: Bool = false
		
		var body: some View {
			Text(type.rawValue)
				.underline(underline)
				.onTapGesture {
					sort(type)
				}
				.onHover { hovering in
					underline = hovering
				}
		}
	}
}
