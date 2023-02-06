//
//  LedgerView.swift
//  ledger
//
//  Created by Chris McElroy on 11/21/22.
//

import SwiftUI

struct LedgerView: View {
	@ObservedObject var storage = Storage.main
	
	@State var sorter: ((Transaction, Transaction) -> Bool) = { $0.date > $1.date }
	
	var body: some View {
		VStack {
			Text("sort by")
			Spacer().frame(height: 10)
   			HStack(spacing: 20) {
				Text("date").onTapGesture {
					sorter = { $0.date > $1.date }
				}
   				Text("category").onTapGesture {
					sorter = {
						let cat0 = $0.myCategory?.rawValue ?? ""
						let cat1 = $1.myCategory?.rawValue ?? ""
						if cat0 > cat1 { return true }
						else if cat0 == cat1 { return $0.date > $1.date }
						else { return false }
					}
				}
   			}
   			Spacer().frame(height: 20)
			ZStack {
				List(storage.transactions.values.map { $0 }.sorted(by: sorter)) { transaction in
					HStack {
						Spacer()
						ZStack {
							RoundedRectangle(cornerRadius: 10)
								.stroke(Color.white, lineWidth: 2)
								.foregroundColor(.black)
							VStack {
								Text((transaction.description ?? "") + (transaction.merchant ?? ""))
								Text(transaction.totalString())
								HStack(spacing: 20) {
									Text(transaction.date, style: .date)
									Text(transaction.ref ?? "")
								}
								Text(transaction.myCategory?.rawValue ?? "unsorted")
								Text(transaction.notes ?? "")
							}
						}
						.opacity(transaction.myCategory == nil ? 0.25 : 1)
						.frame(minWidth: 300, maxWidth: 500)
						Spacer()
					}
					.frame(height: 100)
				}
			}
			.scrollContentBackground(.hidden)
		}
	}
}
