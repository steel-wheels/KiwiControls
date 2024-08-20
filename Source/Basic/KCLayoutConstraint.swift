/**
 * @file	KCLayoutConstraint.swift
 * @brief	Define KCLayoutConstraint class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import CoconutData
import Foundation

extension NSLayoutConstraint {
	public class func attributeDescription(attribute attr: NSLayoutConstraint.Attribute) -> String {
		let result: String
		switch attr {
		case .left:			result = "left"
		case .right:			result = "right"
		case .top:			result = "top"
		case .bottom:			result = "bottom"
		case .leading:			result = "leading"
		case .trailing:			result = "trailing"
		case .width:			result = "width"
		case .height:			result = "height"
		case .centerX:			result = "centerX"
		case .centerY:			result = "centerY"
		case .lastBaseline:		result = "lastBaseline"
		case .firstBaseline:		result = "firstBaseline"
		//case .notAnAttribute:		result = "nil"
		#if os(iOS)
		case .leftMargin:		result = "leftMargin"
		case .rightMargin:		result = "rightMargin"
		case .topMargin:		result = "topMargin"
		case .bottomMargin:		result = "bottomMargin"
		case .leadingMargin:		result = "leadingMargin"
		case .trailingMargin:		result = "trailingMargin"
		case .centerXWithinMargins:	result = "centerXWithinMargines"
		case .centerYWithinMargins:	result = "centerYWithinMargines"
		#endif
		default:			result = "unknown"
		}
		return result
	}
}
