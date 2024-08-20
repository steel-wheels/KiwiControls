/**
 * @file KCSpriteView.swift
 * @brief Define KCSpriteView class
 * @par Copyright
 *   Copyright (C) 20202Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import SpriteKit
import CoconutData

open class KCSpriteView: KCInterfaceView
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
		if let newview = loadChildXib(thisClass: KCSpriteViewCore.self, nibName: "KCSpriteViewCore") as? KCSpriteViewCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCSpriteViewCore")
		}
	}

	public var scene: CNSpriteScene? { get { return self.coreView.scene }}
	public var isStarted: Bool { get { return coreView.isStarted }}

	public func start() {
		coreView.start()
	}

	open var isPaused: Bool {
		get         { return coreView.isPaused   }
		set(newval) { coreView.isPaused = newval }
	}

	public var children: Array<SKNode> { get {
		return self.coreView.children
	}}

	public func add(child node: SKNode){
		self.coreView.add(child: node)
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(sprite: self)
	}

	private var coreView : KCSpriteViewCore {
		get { return getCoreView() }
	}
}


