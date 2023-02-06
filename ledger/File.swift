//
//  File.swift
//  ledger
//
//  Created by Chris McElroy on 11/23/22.
//

import Foundation

class File: Identifiable, Equatable {
	let id: String
	var inverted: Bool = false
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
		guard let inverted = dict[Key.inverted.rawValue] as? Bool else { return nil }
		guard let id = dict[Key.id.rawValue] as? String else { return nil }
		guard let count = dict[Key.count.rawValue] as? Int else { return nil }
		guard let allTransactions = dict[Key.allTransactions.rawValue] as? [Int] else { return nil }
		guard let sortedTransactions = dict[Key.sortedTransactions.rawValue] as? [Int] else { return nil }
		guard let earliestDate = dict[Key.earliestDate.rawValue] as? Double else { return nil }
		guard let latestDate = dict[Key.latestDate.rawValue] as? Double else { return nil }
		self.id = id
		self.inverted = inverted
		self.count = count
		self.allTransactions = allTransactions
		self.sortedTransactions = sortedTransactions
		self.earliestDate = Date(timeIntervalSinceReferenceDate: earliestDate)
		self.latestDate = Date(timeIntervalSinceReferenceDate: latestDate)
	}
	
	static func == (lhs: File, rhs: File) -> Bool {
		lhs.id == rhs.id
	}
	
	func add(_ transaction: Transaction) {
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
		dict[Key.inverted.rawValue] = inverted
		dict[Key.count.rawValue] = count
		dict[Key.allTransactions.rawValue] = allTransactions
		dict[Key.sortedTransactions.rawValue] = sortedTransactions
		dict[Key.earliestDate.rawValue] = earliestDate?.timeIntervalSinceReferenceDate
		dict[Key.latestDate.rawValue] = latestDate?.timeIntervalSinceReferenceDate
		
		return dict
	}
}

class CSVFormat {
	static var globalMapping = Storage.dictionary(.labelMapping) as? [String: String] ?? [:]
	
	var keyMap: [Key: [Int]] = [:]
	var prepared: Bool = false
	
	init(from line: Substring, sort: (String, CSVFormat, @escaping (Key) -> Void) -> Void) {
		let labels = line.split(separator: ",").map { String($0) }
		for (i, label) in labels.enumerated() {
			if let key = Key(rawValue: CSVFormat.globalMapping[label] ?? "") {
				keyMap[key] = (keyMap[key] ?? []) + [i]
			} else {
				sort(label, self) { key in
					CSVFormat.globalMapping[label] = key.rawValue
					Storage.set(CSVFormat.globalMapping, for: .labelMapping)
					self.keyMap[key] = (self.keyMap[key] ?? []) + [i]
					self.prepared = self.keyMap.count == labels.count
				}
			}
		}
		prepared = keyMap.values.joined().count == labels.count
	}
	
	static func getPrice(from item: String) -> Int? {
		guard item.firstIndex(of: ".")?.utf16Offset(in: item) == item.count - 3 && item.filter({ $0 == "." }).count == 1 else {
			print("error — . not in correct place", item)
			return nil
		}
		guard let price = Int(item.filter({ $0 != "." && $0 != "," })) else {
			print("error — invalid amount", item)
			return nil
		}
		return price
	}
}
