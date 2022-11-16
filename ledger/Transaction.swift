//
//  Transaction.swift
//  ledger
//
//  Created by Chris McElroy on 11/8/22.
//

import Foundation

let dateFormatter = DateFormatter()

struct Transaction {
	// required
	let date: Date
	let amount: Int
	let merchant: String // appendable

	// not required
	let ref: String? // appendable
	let description: String? // appendable
	let notes: String? // appendable
	
	let clearingDate: Date?
	let address: String?
	let fees: Int?
	let category: String?
	let transactionType: String?
	let purchasedBy: String?
	
	// exchange shit i'm not going to worry about yet
	let currency: String?
	let exchangeFrom: String?
	let exchangeTo: String?
	let exchangeRate: String?
	let cardUsed: String?
	
	var total: Int { amount + (fees ?? 0) }
	
	init?(from line: Substring, format: CSVFormat) {
		let items = line.split(separator: ",").map { item in
			var item = item
			if item.first == "\"" {
				item.removeFirst()
			}
			if item.last == "\"" {
				item.removeLast()
			}
			return String(item)
		}
		
		dateFormatter.dateFormat = "MM/dd/yyyy"
		
		guard let dateIndex = format.keyMap[.date]?.first else {
			print("error — no date", line, format)
			return nil
		}
		guard let newDate = dateFormatter.date(from: items[dateIndex]) else {
			print("error — bad date", line, dateIndex)
			return nil
		}
		date = newDate
		
		if let clearingDateIndex = format.keyMap[.clearingDate]?.first {
			guard let newDate = dateFormatter.date(from: items[clearingDateIndex]) else {
				print("error — bad date", line, clearingDateIndex)
				return nil
			}
			clearingDate = newDate
		} else { clearingDate = nil }
		
		guard let amountIndex = format.keyMap[.amount]?.first else {
			print("error — no amount", line, format.keyMap)
			return nil
		}
		guard let newAmount = CSVFormat.getPrice(from: items[amountIndex]) else {
			return nil
		}
		amount = newAmount
		
		if let feesIndex = format.keyMap[.fees]?.first {
			guard let newFees = CSVFormat.getPrice(from: items[feesIndex]) else {
				return nil
			}
			fees = newFees
		} else { fees = nil }
		
		guard let merchantIndicies = format.keyMap[.merchant] else {
			print("error — no merchant")
			return nil
		}
		merchant = String(merchantIndicies.map({ items[$0] }).joined(separator: "\n"))
		
		if let refIndicies = format.keyMap[.ref] {
			ref = String(refIndicies.map({ items[$0] }).joined(separator: "\n"))
		} else { ref = nil }
		
		if let descriptionIndicies = format.keyMap[.description] {
			description = String(descriptionIndicies.map({ items[$0] }).joined(separator: "\n"))
		} else { description = nil }
		
		if let notesIndicies = format.keyMap[.notes] {
			notes = String(notesIndicies.map({ items[$0] }).joined(separator: "\n"))
		} else { notes = nil }
		
		if let addressIndex = format.keyMap[.address]?.first {
			address = items[addressIndex]
		} else { address = nil }
		
		if let categoryIndex = format.keyMap[.category]?.first {
			category = items[categoryIndex]
		} else { category = nil }
		
		if let transactionTypeIndex = format.keyMap[.transactionType]?.first {
			transactionType = items[transactionTypeIndex]
		} else { transactionType = nil }
		
		if let purchasedByIndex = format.keyMap[.purchasedBy]?.first {
			purchasedBy = items[purchasedByIndex]
		} else { purchasedBy = nil }
		
		currency = nil
		exchangeFrom = nil
		exchangeTo = nil
		exchangeRate = nil
		cardUsed = nil
	}
}

class CSVFormat {
	static var globalMapping = Storage.dictionary(.labelMapping) as? [String: String] ?? [:]
	
	var keyMap: [Key: [Int]] = [:]
	
	init(from line: Substring, sort: (String, @escaping (Key) -> Void) -> Void) {
		for (i, label) in line.split(separator: ",").map({ String($0) }).enumerated() {
			if let key = Key(rawValue: CSVFormat.globalMapping[label] ?? "") {
				keyMap[key] = (keyMap[key] ?? []) + [i]
			} else {
				sort(label) { key in
					CSVFormat.globalMapping[label] = key.rawValue
					Storage.set(CSVFormat.globalMapping, for: .labelMapping)
					self.keyMap[key] = (self.keyMap[key] ?? []) + [i]
				}
			}
		}
	}
	
	static func getPrice(from item: String) -> Int? {
		guard item.firstIndex(of: ".")?.utf16Offset(in: item) == item.count - 3 && item.filter({ $0 == "." }).count == 1 else {
			print("error — . not in correct place", item)
			return nil
		}
		guard let price = Int(item.filter({ $0 != "." })) else {
			print("error — invalid amount", item)
			return nil
		}
		return price
	}
}
