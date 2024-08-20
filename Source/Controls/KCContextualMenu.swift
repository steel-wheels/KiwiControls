/**
 * @file KCContextualMenu.swift
 * @brief Define KCContextualMenu class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)

import Cocoa
import Foundation

open class KCContextualMenu
{
	public struct MenuItem {
		var index:	Int
		var label:	String

		public init(index idx: Int, label lab: String){
			index = idx
			label = lab
		}
	}

	private var mContextualMenu:	NSMenu
	private var mSelectedItem:	Int?

	public init() {
		mContextualMenu = NSMenu(title: "Contextual menu")
		mSelectedItem	= nil
	}

	public func add(menuItems items: Array<MenuItem>) {
		let sel = #selector(self.menuAction)
		for item in items {
			let newitem = NSMenuItem(title: item.label, action: sel, keyEquivalent: "")
			newitem.target    = self
			newitem.isEnabled = true
			newitem.tag       = item.index
			mContextualMenu.addItem(newitem)
		}
	}

	@objc private func menuAction(_ item : NSMenuItem) {
		mSelectedItem = item.tag
	}

	public func show(at position: CGPoint, in view: KCView) -> Int? {
		mSelectedItem = nil
		if mContextualMenu.popUp(positioning: mContextualMenu.item(at: 0), at: position, in: view) {
			return mSelectedItem
		} else {
			return nil
		}
	}
}

#endif // os(OSX)

