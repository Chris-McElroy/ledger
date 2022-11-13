//
//  KeyInput.swift
//  ledger
//
//  Created by Chris McElroy on 11/9/22.
//

import SwiftUI

// based off https://stackoverflow.com/a/61155272/8222178
struct KeyEventHandling: NSViewRepresentable {
	let view: KeyView = KeyView()
	
	init(tab: @escaping () -> Void) {
		view.tab = tab
	}
	
	class KeyView: NSView {
		var tab: () -> Void = {}
		
		override var acceptsFirstResponder: Bool { true }
		
		override func keyDown(with event: NSEvent) {
			if event.characters == "\t" {
				tab()
			} else {
				super.keyDown(with: event)
			}
		}
	}

	func makeNSView(context: Context) -> NSView {
		DispatchQueue.main.async { // wait till next event cycle
			view.window?.makeFirstResponder(view)
		}
		return view
	}

	func updateNSView(_ nsView: NSView, context: Context) {
	}
}
