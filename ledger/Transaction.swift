//
//  Transaction.swift
//  ledger
//
//  Created by Chris McElroy on 11/8/22.
//

import Foundation

let dateFormatter = DateFormatter()

struct Transaction {
	let date: Date
	let clearingDate: Date? // description
	let ref: String? // description
	let merchant: String
	let description: String?
	let address: String // description
	let amount: Int
	let currency: String? // exchange shit i'm not going to worry about yet
	let fees: Int? // amount
	let category: String? // description
	let transactionType: String?
	let purchasedBy: String?
	let notes: String?
	let exchangeFrom: String?
	let exchangeTo: String?
	let exchangeRate: String?
	let cardUsed: String?
	
	var total: Int { amount + (fees ?? 0) }
	
	init?(from line: Substring, format: Format) {
		let components = line.split(separator: ",")
		
		dateFormatter.dateFormat = "MM/dd/yyyy"
		date = dateFormatter.date(from: String(components[0])) ?? Date.now
		ref = String(components[1])
		merchant = String(components[2].dropFirst().dropLast())
		address = String(components[3].dropFirst().dropLast())
		guard components[4].dropLast(2).last == "." else {
			print("error — missing . in amount")
			return nil
		}
		amount = Int(String(components[4]).filter({ $0 != "." })) ?? 0
		
		// TODO this should go through each data point and add it in based on what it says in the format
		// the format should combine multiple strings in many cases, so i should combine some of them to be arrays
		// it goes through the top line, sees everything that needs to be added
		// i should pre-edit all the components to not have quotes around them
		// and i should make a helper function for getting the dates
		// and i should make a helper function for getting amounts from the amounts
	}
}

struct CSVFormat {
	let date: Int
	let clearingDate: Int?
	let ref: Int?
	let merchant: Int
	let description: Int?
	let address: Int
	let amount: Int
	let currency: Int?
	let fees: Int?
	let category: Int?
	let transactionType: Int?
	let purchasedBy: Int?
	
	// this should tear through the first line and figure out what goes were
	// each item should have a list of labels it corresponds to
	// i should make that list editable in preferences, not something that's wrote
	// so now i need to make a preferences??
	// interesting
	// maybe i should do that later?
	
	// TODO make an init that splits it all out by line
	
	static func store(_ newText: String, as type: Key) {
		var oldMatches = Storage.array(type) ?? []
		oldMatches.append(newText)
		Storage.set(oldMatches, for: type)
	}
}
