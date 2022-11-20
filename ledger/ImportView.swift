//
//  ImportView.swift
//  ledger
//
//  Created by Chris McElroy on 11/8/22.
//

import SwiftUI

// drag and drop from https://stackoverflow.com/a/60832686/8222178

struct ImportView: View {
	@ObservedObject var storage: Storage = Storage.main
	@State var blinkBorder: String? = nil
	@State private var dragOver = false
	@State var toSort: [(String, (Key) -> Void)] = []
	@State var format: CSVFormat? = nil
	@State var editingMap: Bool = false

	var body: some View {
		ZStack {
			List(storage.files) { file in
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
				.opacity(file.sorted ? 0.25 : 1)
				.frame(height: 60)
			}
			if storage.files.isEmpty {
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
				let file = File(from: url.lastPathComponent)
				if storage.files.contains(file) {
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
			if let transaction = Transaction(from: line, file: file.id, format: format) {
				self.storage.transactions[transaction.id] = transaction
				Storage.set(self.storage.transactions.map { $0.value.toDict() }, for: .transactions)
				file.add(transaction)
			}
		}
		storage.files.append(file)
		Storage.set(storage.files.map { $0.toDict() }, for: .files)
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
	var allTransactions: [Int] = []
	var sortedTransactions: [Int] = []
	var earliestDate: Date? = nil
	var latestDate: Date? = nil
	
	var sorted: Bool { allTransactions.count == sortedTransactions.count }
	
	init(from path: String) {
		id = path
	}
	
	init?(data: Any) {
		guard let dict = data as? [String: Any] else { return nil }
		guard let id = dict[Key.id.rawValue] as? String else { return nil }
		guard let count = dict[Key.count.rawValue] as? Int else { return nil }
		guard let allTransactions = dict[Key.allTransactions.rawValue] as? [Int] else { return nil }
		guard let sortedTransactions = dict[Key.sortedTransactions.rawValue] as? [Int] else { return nil }
		guard let earliestDate = dict[Key.earliestDate.rawValue] as? Double else { return nil }
		guard let latestDate = dict[Key.latestDate.rawValue] as? Double else { return nil }
		self.id = id
		self.count = count
		self.allTransactions = allTransactions
		self.sortedTransactions = sortedTransactions
		self.earliestDate = Date(timeIntervalSinceReferenceDate: earliestDate)
		self.latestDate = Date(timeIntervalSinceReferenceDate: latestDate)
	}
	
	static func == (lhs: File, rhs: File) -> Bool {
		lhs.id == rhs.id
	}
	
	mutating func add(_ transaction: Transaction) {
		count += 1
		allTransactions.append(transaction.id)
		if transaction.date < earliestDate ?? Date.distantFuture {
			self.earliestDate = transaction.date
		}
		if transaction.date > latestDate ?? Date.distantPast {
			self.latestDate = transaction.date
		}
	}
	
	func toDict() -> [String: Any] {
		var dict: [String: Any] = [:]
		dict[Key.id.rawValue] = id
		dict[Key.count.rawValue] = count
		dict[Key.allTransactions.rawValue] = allTransactions
		dict[Key.sortedTransactions.rawValue] = sortedTransactions
		dict[Key.earliestDate.rawValue] = earliestDate?.timeIntervalSinceReferenceDate
		dict[Key.latestDate.rawValue] = latestDate?.timeIntervalSinceReferenceDate
		
		return dict
	}
}

