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
			Text("sort by")
			HStack(spacing: 0) {
				// TODO have these do anything
				Text("date")
				Spacer().frame(width: 20)
				Text("file")
			}
			if let transaction {
				VStack {
					Text(transaction.date)
					Text(String(transaction.amount))
					Text(transaction.description)
					Text(transaction.merchant)
				}
				HStack {
					VStack {
						SortButton(type: .date, sort: sort)
						SortButton(type: .merchant, sort: sort)
						SortButton(type: .amount, sort: sort)
						SortButton(type: .description, sort: sort)
					}
					VStack {
						SortButton(type: .ref, sort: sort)
						SortButton(type: .clearingDate, sort: sort)
						SortButton(type: .fees, sort: sort)
						SortButton(type: .address, sort: sort)
						SortButton(type: .category, sort: sort)
						SortButton(type: .transactionType, sort: sort)
						SortButton(type: .purchasedBy, sort: sort)
						SortButton(type: .notes, sort: sort)
					}
				}
			} else {
				Spacer()
			}
			.padding(.all, 20)
			.background(.black)
		}
		.onAppear {
			transaction = storage.transactions.sorted(by: { $0.value.date < $1.value.date }).first?.value
		}
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
