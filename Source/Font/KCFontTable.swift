/**
 * @file	KCFontTable.swift
 * @brief	Define KCFontTable class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import CoconutData
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

public class KCFontTable
{
	public enum FontStyle {
		case Title
		case Headline
		case Body
		case Caption
	}

	public static let sharedFontTable = KCFontTable()

	private let titleSize:		CGFloat		= 22
	private let headlineSize:	CGFloat		= 16
	private let bodySize:		CGFloat		= 14
	private let captionSize:	CGFloat		= 12

	private init() {

	}

	public func font(withStyle style: FontStyle) -> CNFont {
		#if os(OSX)
			var result: CNFont
			switch style {
			case .Title:	result = CNFont.messageFont(ofSize:	titleSize)
			case .Headline:	result = CNFont.boldSystemFont(ofSize:	headlineSize)
			case .Body:	result = CNFont.messageFont(ofSize:	bodySize)
			case .Caption:	result = CNFont.messageFont(ofSize:	captionSize)
			}
			return result
		#else
			var result: CNFont
			switch style {
			case .Title:	result = CNFont.preferredFont(forTextStyle: CNFont.TextStyle.title1)
			case .Headline:	result = CNFont.preferredFont(forTextStyle: CNFont.TextStyle.headline)
			case .Caption:	result = CNFont.preferredFont(forTextStyle: CNFont.TextStyle.caption1)
			case .Body:	result = CNFont.preferredFont(forTextStyle: CNFont.TextStyle.body)
			}
			return result
		#endif
	}
}
