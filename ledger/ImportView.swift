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
	@State var blinkBorder: String? = nil
	@State private var dragOver = false
	@State var toSort: [(String, (Key) -> Void)] = []
	@State var format: CSVFormat? = nil
	@State var editingMap: Bool = false

	var body: some View {
		ZStack {
			List(files) { file in
				ZStack {
					RoundedRectangle(cornerRadius: 10)
						.stroke(file.id != blinkBorder ? Color.white : Color.clear, lineWidth: 2)
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
			if editingMap {
				ScrollView {
					LazyVStack(spacing: 10) {
						ForEach(0..<(CSVFormat.globalMapping.count), id: \.self) { i in
							let name = CSVFormat.globalMapping.keys.sorted()[i]
							let category = CSVFormat.globalMapping[name] ?? "none"
							HStack {
								Text(name + " -> " + category + " ")
								Text("X")
									.onTapGesture {
										CSVFormat.globalMapping[name] = nil
										Storage.set(CSVFormat.globalMapping, for: .labelMapping)
										editingMap = false
										editingMap = true
									}
							}
						}
					}
				}
				.background(.black)
			}
			VStack {
				Spacer()
				Text(editingMap ? "stop editing" : "edit categories")
					.onTapGesture {
						editingMap.toggle()
					}
					.padding(.all, 10)
			}
			if let (item, sorter) = toSort.first {
				FormatSorter(item: item) { key in
					sorter(key)
					toSort.removeFirst()
				}
			}
		}
		.scrollContentBackground(.hidden)
		.frame(minWidth: 300, maxWidth: 500)
		.onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
			providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
				guard let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String), let content = try? String(contentsOf: url).split(whereSeparator: { $0 == "\n" || $0 == "\r\n" }) else {
					print("failed to import")
					return
				}
				var file = File(from: url.lastPathComponent)
				if files.contains(file) {
					print("same name")
					blinkBorder(of: file)
					return
				}
				let format = CSVFormat(from: content.first ?? "") { item, format, sorter in
					toSort.append((item, { key in
						sorter(key)
						if format.prepared {
							sortTransactions(from: content, file: file, format: format)
						}
					}))
				}
				if format.prepared {
					sortTransactions(from: content, file: file, format: format)
				}
			})
			return true
		}
//			.border(dragOver ? Color.red : Color.clear) // TODO react to dragover changing
	}
	
	func sortTransactions(from content: [Substring], file: File, format: CSVFormat) {
		var file = file
		for line in content.dropFirst() {
			if let transaction = Transaction(from: line, format: format) {
				self.transactions.append(transaction)
				file.add(transaction)
			}
		}
		files.append(file)
	}
	
	func blinkBorder(of file: File) {
		blinkBorder = file.id
		var count = 0
		print("setting up")
		DispatchQueue.main.async {
			Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { timer in
				if blinkBorder != nil {
					blinkBorder = nil
				} else {
					blinkBorder = file.id
				}
				count += 1
				print("blinking")
				if count > 3 && blinkBorder == nil {
					timer.invalidate()
				}
			})
		}
	}
}

struct FormatSorter: View {
	let item: String
	let sort: (Key) -> Void
	
	var body: some View {
		HStack(spacing: 0) {
			Spacer()
			Text(item)
			Spacer()
			VStack {
				SortButton(type: .date, sort: sort)
				SortButton(type: .merchant, sort: sort)
				SortButton(type: .amount, sort: sort)
				SortButton(type: .description, sort: sort)
			}
			Spacer().frame(width: 20)
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
		.padding(.all, 20)
		.background(.black)
	}
	
	struct SortButton: View {
		let type: Key
		let sort: (Key) -> Void
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

struct File: Identifiable, Equatable {
	let id: String
	var count: Int = 0
	var earliestDate: Date? = nil
	var latestDate: Date? = nil
	
	init(from path: String) {
		id = path
	}
	
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
