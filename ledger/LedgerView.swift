//
//  LedgerView.swift
//  ledger
//
//  Created by Chris McElroy on 11/21/22.
//

import SwiftUI

struct LedgerView: View {
	@ObservedObject var storage = Storage.main
	
	var body: some View {
		ZStack {
			List(storage.transactions.values.map { $0 }) { transaction in
				ZStack {
					RoundedRectangle(cornerRadius: 10)
						.stroke(Color.white, lineWidth: 2)
						.foregroundColor(.black)
					VStack {
						Text(transaction.description ?? "")
						HStack(spacing: 20) {
							Text(transaction.amount.formatted(.currency(code: "USD")))
							Text(transaction.notes ?? "")
						}
					}
				}
				.opacity(transaction.myCategory == nil ? 0.25 : 1)
				.frame(height: 60)
			}
		}
		.scrollContentBackground(.hidden)
		.frame(minWidth: 300, maxWidth: 500)
	}
}
