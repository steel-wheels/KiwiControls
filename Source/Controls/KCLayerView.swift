/**
 * @file	KCLayerView.swift
 * @brief	Define KCLayerView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 * reference: https://stackoverflow.com/questions/2306870/is-there-a-way-to-pause-a-cabasicanimation
 */

import CoconutData
import CoreGraphics
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

#if os(OSX)
public protocol KCLayerDelegate: CALayerDelegate, CAAnimationDelegate {
}
#else
public protocol KCLayerDelegate {
}
#endif

public class KCLayer: CALayer {
	public static let RepeatCountKey = "repeatCount"

	class public override func needsDisplay(forKey key: String) -> Bool {
		if key == RepeatCountKey {
			return true
		} else {
			return super.needsDisplay(forKey: key)
		}
	}
}

open class KCLayerView: KCInterfaceView, KCLayerDelegate
{
	public typealias UpdateStateCallback = (_ state: CNAnimationState) -> Void

	private let LayerSpeed: Float	= 1.0

	private var mMinimumSize:	CGSize
	private var mLogicalFrame:	CGRect
	private var mAnimationState:	CNAnimationState
	private var mStateCallback:	UpdateStateCallback?
	private var mDrawCount:		Int32

	public override init(frame: CGRect) {
		mMinimumSize	= CGSize(width: 128.0, height: 128.0)
		mLogicalFrame	= CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		mAnimationState	= .idle
		mStateCallback	= nil
		mDrawCount	= 0
		super.init(frame: frame)
		setup()
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		stopAsync()
	}

	private func setup() {
		#if os(OSX)
		let newlayer	  = KCLayer()
		self.layer        = newlayer
		newlayer.delegate = self
		self.wantsLayer   = true
		#endif
	}

	private func getLayer() -> CALayer {
		#if os(OSX)
		if let lay = self.layer {
			return lay
		} else {
			fatalError("Can not happen at \(#function)")
		}
		#else
		return self.layer
		#endif
	}

	public var minimumSize: CGSize {
		get { return mMinimumSize }
		set(newsize) {
			if newsize.width > 0.0 && newsize.height > 0.0 {
				mMinimumSize = newsize
				self.invalidateIntrinsicContentSize()
			}
		}
	}

	public var logicalFrame: CGRect {
		get { return mLogicalFrame }
		set(newfrm) {
			if newfrm.size.width > 0.0 && newfrm.size.height > 0.0 {
				mLogicalFrame = newfrm
			} else {
				CNLog(logLevel: .error, message: "Invalid frame size: \(newfrm)", atFunction: #function, inFile: #file)
			}
		}
	}

	public func setCallback(updateStateCallback cbfunc: @escaping UpdateStateCallback) {
		mStateCallback = cbfunc
	}

	public var state: CNAnimationState {
		get { return mAnimationState }
	}

	private func updateState(state stat: CNAnimationState) {
		if mAnimationState != stat {
			mAnimationState = stat
			if let cbfunc = mStateCallback {
				cbfunc(stat)
			}
		}
	}

	public func start(duration durval: TimeInterval, repeatCount count: Int) {
		switch mAnimationState {
		case .idle:
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				self.startAsync(duration: durval, repeatCount: count)
			})
		case .run, .pause:
			CNLog(logLevel: .error, message: "Already running: \(mAnimationState.description)", atFunction: #function, inFile: #file)
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)
		}
	}

	public func stop() {
		switch mAnimationState {
		case .idle:
			CNLog(logLevel: .error, message: "Already stopped", atFunction: #function, inFile: #file)
		case .run, .pause:
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				self.stopAsync()
			})
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)
		}
	}

	public func suspend(){
		switch mAnimationState {
		case .idle:
			CNLog(logLevel: .error, message: "Already idle", atFunction: #function, inFile: #file)
		case .pause:
			CNLog(logLevel: .error, message: "Already pause", atFunction: #function, inFile: #file)
		case .run:
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				self.suspendAsync()
			})
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)
		}
	}

	public func resume(){
		switch mAnimationState {
		case .idle:
			CNLog(logLevel: .error, message: "Already idle", atFunction: #function, inFile: #file)
		case .run:
			CNLog(logLevel: .error, message: "Already run", atFunction: #function, inFile: #file)
		case .pause:
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				self.resumeAsync()
			})
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)
		}
	}

	private func startAsync(duration durval: TimeInterval, repeatCount count: Int) {
		switch mAnimationState {
		case .idle:
			/* Reset the count */
			mDrawCount = 0

			let timer = CABasicAnimation(keyPath: KCLayer.RepeatCountKey)
			timer.duration	  		= durval
			timer.repeatCount 		= Float(count)
			timer.isRemovedOnCompletion	= true
			#if os(OSX)
			timer.delegate			= self
			#endif

			let lay				= getLayer()
			lay.speed   			= LayerSpeed
			CATransaction.begin()
			lay.add(timer, forKey: KCLayer.RepeatCountKey)
			CATransaction.commit()

			updateState(state: .run)
		case .pause, .run:
			CNLog(logLevel: .error, message: "Not idle state", atFunction: #function, inFile: #file)
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)

		}
	}

	private func stopAsync() {
		switch mAnimationState {
		case .idle, .pause:
			CNLog(logLevel: .error, message: "Not run state", atFunction: #function, inFile: #file)
		case .run:
			let lay		= getLayer()
			lay.speed   	= 0.0		/* Stop animation */
			lay.removeAllAnimations()

			updateState(state: .idle)
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)
		}
	}

	private func suspendAsync() {
		switch mAnimationState {
		case .run:
			let lay		   	= getLayer()
			let pausedTime     	= lay.convertTime(CACurrentMediaTime(), from: nil)
			lay.speed         	= 0.0	/* Stop animation */
			lay.timeOffset 	   	= pausedTime

			updateState(state: .pause)
		case .idle, .pause:
			CNLog(logLevel: .error, message: "Not run state", atFunction: #function, inFile: #file)
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)
		}

	}

	private func resumeAsync() {
		switch mAnimationState {
		case .pause:
			let lay			= getLayer()
			let pausedTime  	= lay.timeOffset
			lay.speed   		= LayerSpeed
			lay.timeOffset		= 0.0
			let timeSincePause	= lay.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
			lay.beginTime		= timeSincePause

			updateState(state: .run)
		case .idle, .run:
			CNLog(logLevel: .error, message: "Not pause state", atFunction: #function, inFile: #file)
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown state", atFunction: #function, inFile: #file)
		}
	}

	public func animationDidStart(_ anim: CAAnimation) {
		CNLog(logLevel: .detail, message: "Did start", atFunction: #function, inFile: #file)
	}

	public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		CNLog(logLevel: .detail, message: "Did stop finished", atFunction: #function, inFile: #file)
		stopAsync()
	}

	open override func draw(_ dirtyRect: CGRect) {
		if let ctxt = self.context {
			draw(context: ctxt, count: mDrawCount)
			mDrawCount = (mDrawCount == Int32.max) ? 1 : mDrawCount + 1
		} else {
			CNLog(logLevel: .error, message: "No context", atFunction: #function, inFile: #file)
		}
	}

	#if os(OSX)
	private var context: CGContext? {
		get { return NSGraphicsContext.current?.cgContext }
	}
	#else
	private var context: CGContext? {
		get { return UIGraphicsGetCurrentContext() }
	}
	#endif

	open func draw(context ctxt: CGContext, count cnt: Int32) {
		CNLog(logLevel: .detail, message: "Draw layer: \(cnt)", atFunction: #function, inFile: #file)
	}

	public override var intrinsicContentSize: CGSize {
		get { return  CGSize.minSize(mMinimumSize, self.limitSize) }
	}
}

