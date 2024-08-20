/**
 * @file	KCPreference.swift
 * @brief	Define KCPreference class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData
import Foundation

public class KCWindowPreference: CNPreferenceTable
{
	public var spacing			: CGFloat
	public var backgroundColor		: CNColor
	#if os(OSX)
	public var mainWindowSize		: CGSize?
	#endif

	public init(){
		spacing			= 8.0
		backgroundColor		= CNColor.white
		#if os(OSX)
			mainWindowSize	= nil
		#endif
		super.init(sectionName: "WindowPreference")
	}
}

extension CNPreference
{
	public var windowPreference: KCWindowPreference { get {
		return get(name: "window", allocator: {
			() -> KCWindowPreference in
				return KCWindowPreference()
		})
	}}
}



