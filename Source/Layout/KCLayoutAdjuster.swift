/**
 * @file	KCLayoutAdjuster.swift
 * @brief	Define KCLayoutAdjuster class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

public class KCLayoutAdjuster : KCViewVisitor
{
	private struct Target {
		var	width:	Bool
		var	height:	Bool
		public init(width w: Bool, height h: Bool){
			width  = w
			height = h
		}
	}

	private var mMaxSize: 		CGSize
	private var mTargets:		CNStack<Target>

	public init(maxSize sz: CGSize) {
		mMaxSize = sz
		mTargets = CNStack<Target>()
		super.init()

		pushTarget(target: Target(width: true, height: true))
	}

	open override func visit(root view: KCRootView){
		let coreview: KCInterfaceView = view.getCoreView()
		coreview.accept(visitor: self)
		adjustSize(view: view, size: mMaxSize)
	}

	open override func visit(stack view: KCStackView){
		let currenttarg = currentTarget()
		switch view.axis {
		case .horizontal:
			if view.arrangedSubviews().count > 1 {
				// Restrict width adjustment
				let newtarg = Target(width: false, height: currenttarg.height)
				pushTarget(target: newtarg)
				for subview in view.arrangedSubviews() {
					subview.accept(visitor: self)
				}
				popTarget()
			} else {
				for subview in view.arrangedSubviews() {
					subview.accept(visitor: self)
				}
			}
			adjustSize(view: view, size: mMaxSize)
		case .vertical:
			if view.arrangedSubviews().count > 1 {
				// Restrict height adjustment
				let newtarg = Target(width: currenttarg.width, height: false)
				pushTarget(target: newtarg)
				for subview in view.arrangedSubviews() {
					subview.accept(visitor: self)
				}
				popTarget()
			} else {
				for subview in view.arrangedSubviews() {
					subview.accept(visitor: self)
				}
			}
			adjustSize(view: view, size: mMaxSize)
		@unknown default:
			CNLog(logLevel: .error, message: "Unsupported axis", atFunction: #function, inFile: #file)
		}
	}

	open override func visit(labeledStack view: KCLabeledStackView){
		view.contentsView.accept(visitor: self)
		adjustSize(view: view, size: mMaxSize)
	}

	open override func visit(list view: KCListView){
		let currenttarg = currentTarget()
		let newtarg = Target(width: currenttarg.width, height: false)
		pushTarget(target: newtarg)
		for cell in view.subCellViews {
			adjustCellSize(cell: cell, size: mMaxSize)
		}
		popTarget()

		adjustSize(view: view, size: mMaxSize)
	}

	open override func visit(coreView view: KCInterfaceView){
		adjustSize(view: view, size: mMaxSize)
	}

	private func adjustSize(view v: KCView, size sz: CGSize) {
		let currenttarg = currentTarget()
		if currenttarg.width || currenttarg.height {
			var updated   = false
			var newwidth  = v.frame.width
			var newheight = v.frame.height
			if currenttarg.width && (mMaxSize.width < newwidth) {
				newwidth = mMaxSize.width ; updated = true
			}
			if currenttarg.height && (mMaxSize.height < newheight){
				newheight = mMaxSize.height ; updated = true
			}
			if updated {
				let newsize   = CGSize(width: newwidth, height: newheight)
				v.setFrameSize(newsize)
			}
		}
	}

	private func adjustCellSize(cell c: KCTableCellView, size sz: CGSize) {
		if sz.width > mMaxSize.width {
			let newsize = CGSize(width: sz.width, height: c.frame.width)
			c.setFrame(size: newsize)
		}
	}

	private func pushTarget(target targ: Target){
		mTargets.push(targ)
	}

	private func popTarget(){
		let _ = mTargets.pop()
	}

	private func currentTarget() -> Target {
		if let targ = mTargets.peek() {
			return targ
		} else {
			return Target(width: true, height: false)
		}
	}
}

