/**
 * @file	KCRootView.swift
 * @brief	Define KCRootView class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

open class KCRootView: KCInterfaceView
{
	private var mStyleListner:	CNObserverDictionary.ListnerHolder?

	#if os(OSX)
	public override init(frame : NSRect){
		mStyleListner	= nil
		super.init(frame: frame) ;
		self.wantsLayer = true
	}
	#else
	public override init(frame: CGRect){
		mStyleListner	= nil
		super.init(frame: frame) ;
	}
	#endif

	public convenience init(){
		#if os(OSX)
		let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 272)
		#else
		let frame = CGRect(x: 0.0, y: 0.0, width: 256, height: 256)
		#endif
		self.init(frame: frame)

		let spref = CNPreference.shared.systemPreference
		mStyleListner = spref.addObsertverForStyle(callback: {
			(_ style: CNInterfaceStyle) -> Void in
			self.update(style: style)
		})
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder) ;
		#if os(OSX)
		self.wantsLayer = true
		#endif

		let spref = CNPreference.shared.systemPreference
		mStyleListner = spref.addObsertverForStyle(callback: {
			(_ style: CNInterfaceStyle) -> Void in
			self.update(style: style)
		})
	}

	deinit {
		/* Remove color observer */
		if let listner = mStyleListner {
			let spref = CNPreference.shared.systemPreference
			spref.removeObserver(listnerHolder: listner)
		}
	}

	public func setup(childView child: KCView, edgeInsets insets: KCEdgeInsets){
		KCView.setAutolayoutMode(view: self)

		self.addSubview(child)
		super.allocateSubviewLayout(subView: child, in: insets)
		setCoreView(view: child)

		updateAppearance()
	}

	private func update(style stl: CNInterfaceStyle) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			/* Update self */
			self.updateAppearance()
			/* Update contents */
			if let coreview: KCInterfaceView = self.getCoreView() {
				coreview.updateAppearance()
			}
            /* Update appearance */
            self.updateAppearance()
		})
	}

	open override func updateAppearance() {
		super.updateAppearance()
        let vpref = CNPreference.shared.viewPreference
        #if os(OSX)
        if let lyr = self.layer {
            lyr.backgroundColor = vpref.controlBackgroundColor(status: .normal).cgColor
        }
        #else
        self.backgroundColor = vpref.controlBackgroundColor(status: .normal)
        #endif
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(root: self)
	}
}

