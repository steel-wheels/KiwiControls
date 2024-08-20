/**
 * @file	KCDocument.swift
 * @brief	Define KCDocument class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
import Foundation

open class KCDocument: NSDocument
{
	public override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		guard let action = item.action else {
			return false
		}
		switch action {
		case #selector(save(_:)):
			return false
		case #selector(saveAs(_:)):
			return false
		case #selector(duplicate(_:)):
			return false
		case #selector(rename(_:)):
			return false
		case #selector(move(_:)):
			return false
		case #selector(runPageLayout(_:)):
			return false
		case #selector(revertToSaved(_:)):
			return false
		default:
			return super.validateUserInterfaceItem(item)
		}
	}
}

#endif // os(OSX)

