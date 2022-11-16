//
//  StorageHelper.swift
//  ledger
//
//  Created by Chris McElroy on 11/9/22.
//

import Foundation

enum Key: String {
	case transactions
	case files
	case labelMapping
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
//	case currency = "currency"
//	case exchangeFrom = "exchange from"
//	case exchangeTo = "exchange to"
//	case exchangeRate = "exchange rate"
//	case cardUsed = "card used"
}

class Storage {
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
