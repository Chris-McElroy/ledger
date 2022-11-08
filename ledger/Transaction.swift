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
	let ref: String
	let name: String
	let address: String
	let amount: Int
	
	init(date: Date, ref: String, name: String, address: String, amount: Int) {
		self.date = date
		self.ref = ref
		self.name = name
		self.address = address
		self.amount = amount
	}
	
	init?(from line: Substring) {
		let components = line.split(separator: ",")
		dateFormatter.dateFormat = "MM/dd/yyyy"
		date = dateFormatter.date(from: String(components[0])) ?? Date.now
		ref = String(components[1])
		name = String(components[2].dropFirst().dropLast())
		address = String(components[3].dropFirst().dropLast())
		guard components[4].dropLast(2).last == "." else {
			print("error — missing . in amount")
			return nil
		}
		amount = Int(String(components[4]).filter({ $0 != "." })) ?? 0
	}
}
