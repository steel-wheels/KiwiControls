/**
 * @file	KCType.swift
 * @brief	Define KCType class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

#if os(iOS)
	import UIKit
#else
	import AppKit
#endif

#if os(iOS)
	public typealias KCResponder		= UIResponder
	public typealias KCTextViewDelegate	= UITextViewDelegate
	public typealias KCLayoutAttribute	= NSLayoutConstraint.Attribute
	public typealias KCLayoutRelation	= NSLayoutConstraint.Relation
	public typealias KCLayoutPriority	= UILayoutPriority
	public typealias KCLineBreakMode	= NSLineBreakMode
	public typealias KCLabel		= UILabel
	public typealias KCWindow		= UIWindow
#else
	public typealias KCResponder		= NSResponder
	public typealias KCTextViewDelegate	= NSTextViewDelegate
	public typealias KCLayoutAttribute	= NSLayoutConstraint.Attribute
	public typealias KCLayoutRelation	= NSLayoutConstraint.Relation
	public typealias KCLayoutPriority	= NSLayoutConstraint.Priority
	public typealias KCLineBreakMode	= NSLineBreakMode
	public typealias KCWindowDelegate 	= NSWindowDelegate
	public typealias KCLabel		= NSTextField
	public typealias KCWindow		= NSWindow
#endif

#if os(OSX)
public extension NSResponder {
	var next: NSResponder? {
		return self.nextResponder
	}
}
#endif

#if os(iOS)
protocol KCWindowDelegate {
	/* Dummy for iOS */
}
#endif

#if os(iOS)
	public typealias KCEdgeInsets		= UIEdgeInsets

	public func KCEdgeInsetsInsetRect(_ rect: CGRect, _ inset: KCEdgeInsets) -> CGRect {
		return rect.inset(by: inset)
	}
#else
	public typealias KCEdgeInsets 		= NSEdgeInsets

	public func KCEdgeInsetsInsetRect(_ rect: CGRect, _ inset: KCEdgeInsets) -> CGRect {
		let inseth:  CGFloat = inset.left + inset.right
		let originx: CGFloat
		let width:   CGFloat
		if inseth <= rect.size.width {
			originx = rect.origin.x + inset.left
			width   = rect.size.width - inseth
		} else {
			originx = rect.origin.x
			width   = rect.size.width
		}

		let insetv:  CGFloat = inset.top + inset.bottom
		let originy: CGFloat
		let height:  CGFloat
		if insetv <= rect.size.height {
			originy = rect.origin.y + inset.top
			height  = rect.size.height - insetv
		} else {
			originy = rect.origin.y
			height  = rect.size.height
		}
		return CGRect(x: originx, y: originy, width: width, height: height)
	}
#endif

public extension KCEdgeInsets {
	var description: String {
		get {
			let l = self.left
			let t = self.top
			let b = self.bottom
			let r = self.right
			return "(left:\(l), top:\(t), bottom:\(b), right:\(r))"
		}
	}
}


