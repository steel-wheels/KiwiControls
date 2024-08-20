/**
 * @file KCRadioButton.swift
 * @brief Define KCRadioButton class
 * @par Copyright
 *   Copyright (C) 20202Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

public class KCRadioButton: KCInterfaceView
{
	public typealias CallbackFunction = KCRadioButtonCore.CallbackFunction

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
		if let newview = loadChildXib(thisClass: KCRadioButtonCore.self, nibName: "KCRadioButtonCore") as? KCRadioButtonCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCRadioButtonCore")
		}
	}

	public var buttonId: Int? {
		get         { return coreView.buttonId }
		set(newval) { coreView.buttonId = newval }
	}

	public var title: String {
		get         { return coreView.title }
		set(newval) { coreView.title = newval }
	}

	public var state: CNButtonState {
		get         { return coreView.state }
		set(newval) { coreView.state = newval }
	}

	public var minLabelWidth: Int {
		get         { return coreView.minLabelWidth }
		set(newval) { coreView.minLabelWidth = newval }
	}

	public var callback: CallbackFunction? {
		get         { return coreView.callback }
		set(newval) { coreView.callback = newval }
	}

    open override func updateAppearance() {
        super.updateAppearance()
        coreView.updateAppearance()
    }

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(radioButton: self)
	}

	private var coreView : KCRadioButtonCore {
		get { return getCoreView() }
	}
}

