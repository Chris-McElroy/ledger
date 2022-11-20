//
//  Transaction.swift
//  ledger
//
//  Created by Chris McElroy on 11/8/22.
//

import Foundation

let dateFormatter = DateFormatter()

enum MyCategory: String {
	case income, school, goods, groceries
}

struct Transaction: Identifiable {
	let id: Int
	let file: String
	var myCategory: MyCategory? = nil
	
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
	
	init?(from line: Substring, file: String, format: CSVFormat) {
		id = Storage.getUniqueID()
		self.file = file
		
		var items: [String] = [""]
		var outsideQuotes = true
		for c in line {
			if c == "," && outsideQuotes {
				items.append("")
			} else if c == "\"" {
				if items.last == "" {
					outsideQuotes.toggle()
				} else if !outsideQuotes {
					outsideQuotes = true
				} else {
					print("problem with quotes", line, items)
				}
			} else {
				items[items.count - 1].append(c)
			}
		}
		
		if items.count != format.keyMap.values.joined().count {
			print("error — items don't line up")
			print(line)
			print(items)
			return nil
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
			print("failed line", line, items)
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
	
	init?(data: Any) {
		guard let dict = data as? [String: Any] else { return nil }
		
		guard let id = dict[Key.id.rawValue] as? Int else { return nil }
		guard let file = dict[Key.file.rawValue] as? String else { return nil }
		guard let date = dict[Key.date.rawValue] as? Double else { return nil }
		guard let amount = dict[Key.amount.rawValue] as? Int else { return nil }
		guard let merchant = dict[Key.amount.rawValue] as? String else { return nil }
		self.id = id
		self.file = file
		self.date = Date(timeIntervalSinceReferenceDate: date)
		self.amount = amount
		self.merchant = merchant
		
		if let myCategory = dict[Key.myCategory.rawValue] as? String {
			self.myCategory = MyCategory(rawValue: myCategory)
		} else { self.myCategory = nil }
		ref = dict[Key.ref.rawValue] as? String
		description = dict[Key.ref.rawValue] as? String
		notes = dict[Key.ref.rawValue] as? String
		if let clearingDate = dict[Key.clearingDate.rawValue] as? Double {
			self.clearingDate = Date(timeIntervalSinceReferenceDate: clearingDate)
		} else { self.clearingDate = nil }
		address = dict[Key.ref.rawValue] as? String
		fees = dict[Key.ref.rawValue] as? Int
		category = dict[Key.ref.rawValue] as? String
		transactionType = dict[Key.ref.rawValue] as? String
		purchasedBy = dict[Key.ref.rawValue] as? String
		currency = dict[Key.ref.rawValue] as? String
		exchangeFrom = dict[Key.ref.rawValue] as? String
		exchangeTo = dict[Key.ref.rawValue] as? String
		exchangeRate = dict[Key.ref.rawValue] as? String
		cardUsed = dict[Key.ref.rawValue] as? String
	}
	
	func toDict() -> [String: Any] {
		var dict: [String: Any] = [:]
		dict[Key.id.rawValue] = id
		dict[Key.file.rawValue] = file
		dict[Key.myCategory.rawValue] = myCategory?.rawValue
		dict[Key.date.rawValue] = date.timeIntervalSinceReferenceDate
		dict[Key.amount.rawValue] = amount
		dict[Key.merchant.rawValue] = merchant
		dict[Key.ref.rawValue] = ref
		dict[Key.description.rawValue] = description
		dict[Key.notes.rawValue] = notes
		dict[Key.clearingDate.rawValue] = clearingDate?.timeIntervalSinceReferenceDate
		dict[Key.address.rawValue] = address
		dict[Key.fees.rawValue] = fees
		dict[Key.category.rawValue] = category
		dict[Key.transactionType.rawValue] = transactionType
		dict[Key.purchasedBy.rawValue] = purchasedBy
		dict[Key.currency.rawValue] = currency
		dict[Key.exchangeFrom.rawValue] = exchangeFrom
		dict[Key.exchangeTo.rawValue] = exchangeTo
		dict[Key.exchangeRate.rawValue] = exchangeRate
		dict[Key.cardUsed.rawValue] = cardUsed
		
		return dict
	}
}

class CSVFormat {
	static var globalMapping = Storage.dictionary(.labelMapping) as? [String: String] ?? [:]
	
	var keyMap: [Key: [Int]] = [:]
	var prepared: Bool = false
	
	init(from line: Substring, sort: (String, CSVFormat, @escaping (Key) -> Void) -> Void) {
		let labels = line.split(separator: ",").map { String($0) }
		print("making format", line, labels)
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
		prepared = keyMap.count == labels.count
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
