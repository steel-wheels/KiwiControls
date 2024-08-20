/**
 * @file KCSpriteViewCore.swift
 * @brief Define KCSpriteViewCore class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import SpriteKit
#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCSpriteViewCore : KCCoreView
{
	#if os(OSX)
	@IBOutlet weak var mSpriteView: SKView!
	#else
	@IBOutlet weak var mSpriteView: SKView!
	#endif

	private static let MaxWidth:  CGFloat	= 200
	private static let MaxHeight: CGFloat	= 200

	private var mScene:		CNSpriteScene?
	private var mCurrentSize:	CGSize

	#if os(OSX)
	public override init(frame : NSRect){
		mScene		= nil
		mCurrentSize	= frame.size
		super.init(frame: frame) ;
	}
	#else
	public override init(frame: CGRect){
		mScene		= nil
		mCurrentSize	= frame.size
		super.init(frame: frame) ;
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0,
					   width:  KCSpriteViewCore.MaxWidth,
					   height: KCSpriteViewCore.MaxHeight)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 200, height: 32)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mScene		= nil
		mCurrentSize	= CGSize(width:  KCSpriteViewCore.MaxWidth,
					 height: KCSpriteViewCore.MaxHeight)
		super.init(coder: coder) ;
	}

	public func setup(frame frm: CGRect){
		super.setup(isSingleView: true, coreView: mSpriteView)

		let scene = CNSpriteScene(size: frm.size)
		scene.setupScene()

		mSpriteView.isPaused = true
		mSpriteView.presentScene(scene)
		mScene = scene
	}

	public var scene: CNSpriteScene? { get { return mScene }}

	public var isStarted: Bool { get {
		if let scene = mScene {
			return scene.isStarted
		} else {
			return false
		}
	}}

	public func start() {
		if let scene = mScene {
			scene.start()
		} else {
			CNLog(logLevel: .error, message: "No scene")
		}
	}

	public var isPaused: Bool {
		get         { return mSpriteView.isPaused }
		set(newval) { mSpriteView.isPaused = newval }
	}

	public var children: Array<SKNode> { get {
		if let scene = mScene {
			return scene.children
		} else {
			CNLog(logLevel: .error, message: "No scene", atFunction: #function, inFile: #file)
			return []
		}
	}}

	public func add(child node: SKNode){
		if let scene = mScene {
			scene.addChild(node)
		} else {
			CNLog(logLevel: .error, message: "No scene", atFunction: #function, inFile: #file)
		}
	}

	/*
	public func resize(_ size: CGSize) {
		let adjsize = KCScreen.adjustSize(size: size)
		/* keep the required size */
		mRequiredSize = adjsize
		//self.invalidateIntrinsicContentSize()
		//self.requireLayout()
		//self.notify(viewControlEvent: .updateSize(self))
	}*/

	#if os(OSX)
	open override var fittingSize: CGSize {
		get { return contentsSize() }
	}
	#else
	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return mCurrentSize.resizeWithKeepingAscpect(inSize: size)
	}
	#endif

	open override func setFrameSize(_ newsize: CGSize) {
		if let scene = mScene {
			scene.size = newsize
		}
		super.setFrameSize(newsize)
		mCurrentSize = newsize
	}

	open override var intrinsicContentSize: CGSize { get {
		let csize = contentsSize()
		#if os(iOS)
		if let scene = mScene {
			scene.size = csize
		}
		#endif // iOS
		return csize
	}}

	open override func contentsSize() -> CGSize {
		return mCurrentSize
	}
}

