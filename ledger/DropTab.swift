//
//  DropTab.swift
//  ledger
//
//  Created by Chris McElroy on 11/8/22.
//

import SwiftUI

// drag and drop from https://stackoverflow.com/a/60832686/8222178

struct DropTab: View {
	@State var transactions: [Transaction] = []
	@State private var dragOver = false

	var body: some View {
		Rectangle()
			.foregroundColor(.black)
			.onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
				providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
					guard let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String), let file = try? String(contentsOf: url).split(separator: "\r\n") else {
						print("failed to import")
						return
					}
					for line in file.dropFirst() {
						if let transaction = Transaction(from: line) {
							self.transactions.append(transaction)
						}
					}
					print(transactions)
				})
				return true
			}
			.border(dragOver ? Color.red : Color.clear)
	}
}
