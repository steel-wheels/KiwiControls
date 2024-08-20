/**
 * @file KCColorSelector.swift
 * @brief Define KCColorSelector class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCColorSelector : KCInterfaceView
{
	public typealias CallbackFunction = KCColorSelectorCore.CallbackFunction

	public var color: CNColor {
		get 		{ return coreView.color		}
		set(newcol)	{ coreView.color = newcol 	}
	}

	public var callbackFunc: CallbackFunction? {
		get		{ return coreView.callbackFunc }
		set(newfunc)	{ coreView.callbackFunc = newfunc }
	}

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
		let frame = NSRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#else
		let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder) ;
		setup() ;
	}

	private func setup(){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCColorSelectorCore.self, nibName: "KCColorSelectorCore") as? KCColorSelectorCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCColorSelectorCore")
		}
	}

	open override func updateAppearance() {
		super.updateAppearance()
		coreView.updateAppearance()
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(colorSelector: self)
	}

	private var coreView: KCColorSelectorCore {
		get { return getCoreView() }
	}
}

