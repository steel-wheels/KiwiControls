/**
 * @file	KCBitmapView.swift
 * @brief	Define KCBitmapView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import CoreGraphics
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

open class KCBitmapView: KCLayerView
{
	private var mContext:		CNBitmapContext
	private var mRowCount:		Int
	private var mColumnCount:	Int

	public override init(frame : CGRect){
		mContext     = CNBitmapContext()
		mRowCount    = 10
		mColumnCount = 10
		super.init(frame: frame)
	}

	public convenience init(){
		let frame = CGRect(x: 0.0, y: 0.0, width: 480, height: 270)
		self.init(frame: frame)
	}

	required public init?(coder: NSCoder) {
		mContext     = CNBitmapContext()
		mRowCount    = 10
		mColumnCount = 10
		super.init(coder: coder)
	}

	public var rowCount: Int {
		get		{ return mRowCount }
		set(newval)	{ mRowCount = newval }
	}

	public var columnCount: Int {
		get		{ return mColumnCount   }
		set(newval)	{ mColumnCount = newval }
	}

	public override func draw(context ctxt: CGContext, count cnt: Int32) {
		/* Draw the bitmap */
		self.mContext.draw(context: ctxt, physicalFrame: self.frame, width: self.mColumnCount, height: self.mRowCount)
		/* Update the content of bitmap */
		self.update(bitmapContext: self.mContext, count: cnt)
	}

	open func update(bitmapContext ctxt: CNBitmapContext, count cnt: Int32) {
		CNLog(logLevel: .error, message: "must be override", atFunction: #function, inFile: #file)
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(bitmap: self)
	}
}

