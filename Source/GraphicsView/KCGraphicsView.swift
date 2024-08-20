/*
 * @file	KCGraphicsView.swift
 * @brief	Define KCGraphicsView class
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import Foundation

#if os(iOS)
	import UIKit
#else
	import Cocoa
#endif

public class KCGraphicsView: KCView
{
	#if os(iOS)
	public var currentContext : CGContext? {
		get {
			return UIGraphicsGetCurrentContext()
		}
	}
	#else
	public var currentContext : CGContext? {
		get {
			return NSGraphicsContext.current?.cgContext
		}
	}
	#endif

	#if os(iOS)
	final public override func draw(_ dirtyRect: CGRect){
		drawContext(in: dirtyRect)
		super.draw(dirtyRect)
	}
	#else
	final public override func draw(_ dirtyRect: NSRect){
		drawContext(in: NSRectToCGRect(dirtyRect))
		super.draw(dirtyRect)
	}
	#endif

	private func drawContext(in dirtyRect: CGRect) {
		if let context = currentContext {
			context.saveGState()
			#if os(iOS)
				context.translateBy(x: 0.0, y: bounds.size.height)
				context.scaleBy(x: 1.0, y: -1.0)
			#endif
			drawContent(in: context)

			context.restoreGState()
		}
	}

	open func drawContent(in context: CGContext){
		/* This method will be overridden */
	}

	public override func acceptMouseEvent(mouseEvent event:KCMouseEvent, mousePosition position:CGPoint){
		/* Must be override by sub class */
	}
}
