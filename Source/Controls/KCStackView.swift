/**
 * @file KCStackView.swift
 * @brief Define KCStackView class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCStackView : KCInterfaceView
{
	#if os(OSX)
	public override init(frame : NSRect){
		super.init(frame: frame) ;
		setup()
	}
	#else
	public override init(frame: CGRect){
		super.init(frame: frame)
		setup()
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 270)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 375, height: 346)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup(){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCStackView.self, nibName: "KCStackViewCore") as? KCStackViewCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCStackCore")
		}
	}

	public var axis: CNAxis {
		get 		{ return coreView.axis 		}
		set(newval)	{ coreView.axis = newval	}
	}

	public var alignment: CNAlignment {
		get		{ return coreView.alignment }
		set(newval)	{ coreView.alignment = newval }
	}

	public var distribution: CNDistribution {
		get 		{ return coreView.distributtion }
		set(newval)	{ coreView.distributtion = newval }
	}

	open func addArrangedSubViews(subViews vs:Array<KCView>){
		coreView.addArrangedSubViews(subViews: vs)
	}

	open func addArrangedSubView(subView v: KCView){
		coreView.addArrangedSubView(subView: v)
	}

	public func removeAllArrangedSubviews() {
		coreView.removeAllArrangedSubviews()
	}

	open func arrangedSubviews() -> Array<KCView> {
		return coreView.arrangedSubviews()
	}

	open override func updateAppearance() {
		super.updateAppearance()
		for view in self.arrangedSubviews() {
			if let core = view as? KCInterfaceView {
				core.updateAppearance()
			}
		}
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(stack: self)
	}

	private var coreView: KCStackViewCore {
		get { return getCoreView() }
	}
}

