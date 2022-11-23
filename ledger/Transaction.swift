//
//  Transaction.swift
//  ledger
//
//  Created by Chris McElroy on 11/8/22.
//

import Foundation

let dateFormatter = DateFormatter()

enum MyCategory: String {
	// TODO this is dumb and i should make these changable
	case sweeps = "sweeps"
	case income = "income"
	
	case utilities = "rent and utilities"
	case medical = "medical"
	case groceries = "groceries"
	case car = "car"
	case haircut = "haircut"
	case software = "software"
	
	case goods = "goods"
	case dining = "dining out"
	case exercise = "exercise"
	case vacation = "vacation"
	case gifts = "gifts"
	case games = "games"
	case school = "school"
	
	case climate = "climate"
	case politics = "politics"
	case patreon = "patreon"
}

class Transaction: Identifiable {
	let id: Int
	let file: String
	var myCategory: MyCategory? = nil
	
	// required
	let date: Date
	let amount: Int

	// not required
	let merchant: String? // appendable
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
			print("error — invalid amount", items[amountIndex], format.keyMap[.amount] ?? "")
			return nil
		}
		amount = newAmount
		
		if let feesIndex = format.keyMap[.fees]?.first {
			guard let newFees = CSVFormat.getPrice(from: items[feesIndex]) else {
				return nil
			}
			fees = newFees
		} else { fees = nil }
		
		if let merchantIndicies = format.keyMap[.merchant] {
			merchant = String(merchantIndicies.map({ items[$0] }).joined(separator: "\n"))
		} else { merchant = nil }
		
		if let refIndicies = format.keyMap[.ref] {
			ref = String(refIndicies.map({ items[$0] }).joined(separator: "\n"))
		} else { ref = nil }
		
		if let descriptionIndicies = format.keyMap[.description] {
			print("getting desc", descriptionIndicies, descriptionIndicies.map({ items[$0] }).joined(separator: "\n"), String(descriptionIndicies.map({ items[$0] }).joined(separator: "\n")))
			description = String(descriptionIndicies.map({ items[$0] }).joined(separator: "\n"))
		} else { print("failed to get desc"); description = nil }
		
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
		guard let dict = data as? [String: Any] else { print("error 1"); return nil }
		
		guard let id = dict[Key.id.rawValue] as? Int else { print("error 2"); return nil }
		guard let file = dict[Key.file.rawValue] as? String else { print("error 3"); return nil }
		guard let date = dict[Key.date.rawValue] as? Double else { print("error 4"); return nil }
		guard let amount = dict[Key.amount.rawValue] as? Int else { print("error 5"); return nil }
		self.id = id
		self.file = file
		self.date = Date(timeIntervalSinceReferenceDate: date)
		self.amount = amount
		
		if let myCategory = dict[Key.myCategory.rawValue] as? String {
			self.myCategory = MyCategory(rawValue: myCategory)
		} else { self.myCategory = nil }
		merchant = dict[Key.merchant.rawValue] as? String
		ref = dict[Key.ref.rawValue] as? String
		description = dict[Key.description.rawValue] as? String
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

func priceToString(_ price: Int, currency: String = "USD") -> String {
	return (price < 0 ? "-" : "") + "$" + String(format: "%01d.%02d", abs(price)/100, abs(price) % 100)
}
