//
//  StorageHelper.swift
//  ledger
//
//  Created by Chris McElroy on 11/9/22.
//

import Foundation

enum Key: String {
	case date = "date"
	case clearingDate = "clearing date"
	case ref = "reference"
	case merchant = "merchant"
	case description = "description"
	case address = "address"
	case amount = "amount"
	case fees = "fees"
	case category = "category"
	case transactionType = "transaction type"
	case purchasedBy = "purchased by"
	case notes = "notes"
	case currency = "currency"
	case exchangeFrom = "exchange from"
	case exchangeTo = "exchange to"
	case exchangeRate = "exchange rate"
	case cardUsed = "card used"

	case transactions, allTransactions, sortedTransactions, files, labelMapping, sorted
	case myCategory, file
	case id, count, earliestDate, latestDate
	case uniqueID
}

class Storage: ObservableObject {
	static let main = Storage()
	@Published var transactions: [Int: Transaction] = getTransactions()
	@Published var files: [File] = (Storage.array(.files)?.compactMap { File(data: $0) } ?? []).sorted(by: { a, _ in !a.sorted })
	
	static func getTransactions() -> [Int: Transaction] {
		var newDict: [Int: Transaction] = [:]
		let transactionsList: [Transaction] = Storage.array(.transactions)?.compactMap { Transaction(data: $0) } ?? []
		for transaction in transactionsList {
			newDict[transaction.id] = transaction
		}
		return newDict
	}
	
	static func getUniqueID() -> Int {
		let id = int(.uniqueID)
		Storage.set(id + 1, for: .uniqueID)
		return id
	}
	
	static func array(_ key: Key) -> [Any]? {
		return UserDefaults.standard.array(forKey: key.rawValue)
	}
	
	static func dictionary(_ key: Key) -> [String: Any]? {
		UserDefaults.standard.dictionary(forKey: key.rawValue)
	}
	
	static func int(_ key: Key) -> Int {
		UserDefaults.standard.integer(forKey: key.rawValue)
	}
	
	static func string(_ key: Key) -> String? {
		UserDefaults.standard.string(forKey: key.rawValue)
	}
	
	static func set(_ value: Any?, for key: Key) {
		UserDefaults.standard.setValue(value, forKey: key.rawValue)
	}
}
