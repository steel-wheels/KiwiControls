/**
 * @file	KCCheckBox.swift
 * @brief	Define KCCheckBox class
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

#if os(iOS)
	import UIKit
#else
	import Cocoa
#endif
import CoconutData

open class KCCheckBox: KCInterfaceView
{
	#if os(OSX)
	public override init(frame : NSRect){
		super.init(frame: frame) ;
		setup() ;
	}
	#else
	public override init(frame: CGRect){
		super.init(frame: frame) ;
		setup()
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 156, height: 16)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 200, height: 32)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder) ;
		setup() ;
	}

	private func setup(){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCCheckBox.self, nibName: "KCCheckBoxCore") as? KCCheckBoxCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCCheckBoxCore")
		}
	}

	public var checkUpdatedCallback: ((_ value: Bool) -> Void)? {
		get { return coreView.checkUpdatedCallback }
		set(callback){ coreView.checkUpdatedCallback = callback }
	}

	public var title: String {
		get { return coreView.title }
		set(newstr){ coreView.title = newstr }
	}

	public var isEnabled: Bool {
		get { return coreView.isEnabled }
		set(v) { coreView.isEnabled = v }
	}

	public var status: Bool {
		get 		{ return coreView.status }
		set(newval)	{ coreView.status = newval }
	}

	open override func updateAppearance() {
		coreView.updateAppearance()
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(checkBox: self)
	}

	private var coreView: KCCheckBoxCore {
		get { return getCoreView() }
	}
}

