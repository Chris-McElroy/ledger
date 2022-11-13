//
//  StorageHelper.swift
//  ledger
//
//  Created by Chris McElroy on 11/9/22.
//

import Foundation

enum Key: String {
	case transactions, files
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
