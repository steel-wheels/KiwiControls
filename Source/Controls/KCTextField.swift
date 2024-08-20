/**
 * @file	KCTextField.swift
 * @brief	Define KCTextField class
 * @par Copyright
 *   Copyright (C) 2018-2023 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCTextField : KCInterfaceView
{
	public typealias CallbackFunction = KCTextFieldCore.CallbackFunction

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
		if let newview = loadChildXib(thisClass: KCTextField.self, nibName: "KCTextFieldCore") as? KCTextFieldCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCTextFieldCore")
		}
	}

	public var hasBackgrooundColor: Bool {
		get         { return coreView.hasBackgrooundColor }
		set(newval) { coreView.hasBackgrooundColor = newval }
	}

	public var isBold: Bool {
		get         { return coreView.isBold }
		set(newval) { coreView.isBold = newval }
	}

	public var decimalPlaces: Int {
		get         { return coreView.decimalPlaces }
		set(newval) { coreView.decimalPlaces = newval }
	}

	public var isEditable: Bool {
		get 		{ return coreView.isEditable	}
		set(newval)	{ coreView.isEditable = newval	}
	}

	public var isEnabled: Bool {
		get { return coreView.isEnabled }
		set(v) { coreView.isEnabled = v }
	}

	public var callbackFunction: CallbackFunction? {
		get { return coreView.callbackFunction	}
		set(v) { coreView.callbackFunction = v 	}
	}

	public var text: String {
		get { return coreView.text }
		set(newval){ coreView.text = newval }
	}

	public var number: NSNumber? {
		get { return coreView.number }
		set(newval){ coreView.number = newval }
	}

	public var font: CNFont? {
		get		{ return coreView.font }
		set(font)	{ coreView.font = font }
	}

	public var alignment: NSTextAlignment {
		get	  { return coreView.alignment }
		set(align){ coreView.alignment = align }
	}

	public func setDouble(value val: Double) {
		let rval   = round(value: val, atPoint: 2)
		let valstr = String(format: "%4.2lf", rval)
		text = valstr
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(textField: self)
	}

	private var coreView: KCTextFieldCore {
		get { return getCoreView() }
	}
}

