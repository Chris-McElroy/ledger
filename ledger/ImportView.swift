//
//  ImportView.swift
//  ledger
//
//  Created by Chris McElroy on 11/8/22.
//

import SwiftUI

// drag and drop from https://stackoverflow.com/a/60832686/8222178

struct ImportView: View {
	@State var transactions: [Transaction] = []
	@State var files: [File] = []
	@State private var dragOver = false

	var body: some View {
		ZStack {
			List(files) { file in
				ZStack {
					RoundedRectangle(cornerRadius: 10)
						.stroke(Color.white, lineWidth: 2)
						.foregroundColor(.black)
					VStack {
						Text(file.id)
						HStack(spacing: 20) {
							Text(String(file.count) + " transactions")
							Text((file.earliestDate?.formatted(date: .abbreviated, time: .omitted) ?? "xx") + " - " + (file.latestDate?.formatted(date: .abbreviated, time: .omitted) ?? "xx"))
						}
					}
				}
				.frame(height: 60)
			}
			if files.isEmpty {
				Text("drag files here to import")
			}
		}
		.scrollContentBackground(.hidden)
		.frame(minWidth: 300, maxWidth: 500)
		.onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
			providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
				guard let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String), let content = try? String(contentsOf: url).split(separator: "\r\n") else {
					print("failed to import")
					return
				}
				var file = File(id: url.lastPathComponent)
				if files.contains(file) {
					print("same name")
					blinkBorder(of: file)
					return
				}
				for line in content.dropFirst() {
					if let transaction = Transaction(from: line) {
						self.transactions.append(transaction)
						file.add(transaction)
					}
				}
				files.append(file)
			})
			return true
		}
//			.border(dragOver ? Color.red : Color.clear) // TODO react to dragover changing
	}
	
	func blinkBorder(of file: File) {
		// TODO blink the border of the given file on and off to indicate that it's a repeat
	}
}

struct File: Identifiable, Equatable {
	let id: String
	var count: Int = 0
	var earliestDate: Date? = nil
	var latestDate: Date? = nil
	
	static func == (lhs: File, rhs: File) -> Bool {
		lhs.id == rhs.id
	}
	
	mutating func add(_ transaction: Transaction) {
		count += 1
		if transaction.date < earliestDate ?? Date.distantFuture {
			self.earliestDate = transaction.date
		}
		if transaction.date > latestDate ?? Date.distantPast {
			self.latestDate = transaction.date
		}
	}
}
