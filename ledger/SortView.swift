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
		VStack {
			Spacer()
			Text("sort by")
			HStack(spacing: 0) {
				// TODO have these do anything
				Text("date")
				Spacer().frame(width: 20)
				Text("file")
			}
			Spacer()
			if let transaction {
				VStack {
					Text(transaction.date.formatted(date: .long, time: .omitted))
					Text(priceToString(transaction.amount))
					Text(transaction.description ?? "")
					Text(transaction.ref ?? "")
					Text(transaction.notes ?? "")
					Text(transaction.merchant ?? "")
				}
				Spacer()
				HStack {
					VStack {
						SortButton(type: .sweeps, sort: sort)
						SortButton(type: .income, sort: sort)
					}
					VStack {
						SortButton(type: .utilities, sort: sort)
						SortButton(type: .medical, sort: sort)
						SortButton(type: .groceries, sort: sort)
						SortButton(type: .car, sort: sort)
						SortButton(type: .haircut, sort: sort)
						SortButton(type: .software, sort: sort)
					}
					VStack {
						SortButton(type: .goods, sort: sort)
						SortButton(type: .dining, sort: sort)
						SortButton(type: .exercise, sort: sort)
						SortButton(type: .vacation, sort: sort)
						SortButton(type: .gifts, sort: sort)
						SortButton(type: .games, sort: sort)
						SortButton(type: .school, sort: sort)
					}
					VStack {
						SortButton(type: .climate, sort: sort)
						SortButton(type: .politics, sort: sort)
						SortButton(type: .patreon, sort: sort)
					}
				}
			} else {
				Spacer()
			}
		}
		.padding(.all, 20)
		.background(.black)
		.onAppear {
			transaction = storage.transactions.sorted(by: { $0.value.date < $1.value.date }).first?.value
			print("trans", transaction?.description)
		}
	}
	
	func sort(into category: MyCategory) {
		transaction?.myCategory = category
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
