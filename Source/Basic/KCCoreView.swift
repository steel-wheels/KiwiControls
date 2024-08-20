/**
 * @file	KCCoreView.swift
 * @brief	Define KCCoreView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation
#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif

open class KCCoreView: KCView
{
	private var mIsSingleView:	Bool 					= false
	private var mCoreView:		KCViewBase?				= nil

	public func setup(isSingleView single: Bool, coreView cview: KCViewBase){
		mIsSingleView	= single
		mCoreView	= cview
	}

	#if os(OSX)
	open override var canBecomeKeyView: Bool {
		get {
			if let core = mCoreView {
				return core.canBecomeKeyView
			} else {
				return super.canBecomeKeyView
			}
		}
	}

	open override var needsPanelToBecomeKey: Bool {
		get {
			if let core = mCoreView {
				return core.needsPanelToBecomeKey
			} else {
				return super.needsPanelToBecomeKey
			}
		}
	}

	open override var nextKeyView: NSView? {
		get {
			if let core = mCoreView {
				return core.nextKeyView
			} else {
				return super.nextKeyView
			}
		}
		set(newval){
			if let core = mCoreView {
				core.nextKeyView = newval
			} else {
				super.nextKeyView = newval
			}
		}
	}

	open override var nextValidKeyView: NSView? {
		get {
			if let core = mCoreView {
				return core.nextValidKeyView
			} else {
				return super.nextValidKeyView
			}
		}
	}

	open override var previousKeyView: NSView? {
		get {
			if let core = mCoreView {
				return core.previousKeyView
			} else {
				return super.previousKeyView
			}
		}
	}

	open override var previousValidKeyView: NSView? {
		get {
			if let core = mCoreView {
				return core.previousValidKeyView
			} else {
				return super.previousValidKeyView
			}
		}
	}
	#endif

	#if os(OSX)
	open override var needsUpdateConstraints: Bool {
		get {
			if let core = mCoreView {
				return core.needsUpdateConstraints
			} else {
				return super.needsUpdateConstraints
			}
		}
		set(newval){
			if let core = mCoreView {
				core.needsUpdateConstraints  = newval
				super.needsUpdateConstraints = newval
			} else {
				super.needsUpdateConstraints = newval
			}
		}
	}
	#endif

	open func contentsSize() -> CGSize {
		NSLog("must be override")
		return CGSize.zero
	}

	open func adjustContentsSize(size sz: CGSize) -> CGSize {
		NSLog("must be override")
		return CGSize.zero
	}

	public override func setFrameSize(_ newsize: CGSize) {
		if mIsSingleView {
			if let core = mCoreView {
				core.setFrame(size: newsize)
			}
		}
		super.setFrameSize(newsize)
	}

	public override func setFrameOrigin(_ newpt: CGPoint) {
		if mIsSingleView {
			if let core = mCoreView {
				core.setFrame(origin: newpt)
			}
		}
		super.setFrameOrigin(newpt)
	}

	#if os(OSX)
	open override var fittingSize: CGSize {
		get {
			if let core = mCoreView {
				return core.fittingSize
			} else {
				return super.fittingSize
			}
		}
	}
	#else
	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		if let core = mCoreView {
			return core.sizeThatFits(size)
		} else {
			return super.sizeThatFits(size)
		}
	}
	#endif

	open override var intrinsicContentSize: CGSize {
		get {
			if let core = mCoreView {
				return core.intrinsicContentSize
			} else {
				return super.intrinsicContentSize
			}
		}
	}

	public override func invalidateIntrinsicContentSize() {
		super.invalidateIntrinsicContentSize()
		if let core = mCoreView {
			core.invalidateIntrinsicContentSize()
		}
	}

	public override func setExpandabilities(priorities prival: KCViewBase.ExpansionPriorities) {
		super.setExpandabilities(priorities: prival)
		if mIsSingleView {
			if let core = mCoreView {
				core._setExpansionPriorities(priorities: prival)
			}
		}
	}
}

