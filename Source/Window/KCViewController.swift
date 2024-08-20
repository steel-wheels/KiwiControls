/**
 * @file	KCViewController.swift
 * @brief	Define KCViewController class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

#if os(iOS)
	import UIKit
#else
	import Cocoa
#endif
import CoconutData

#if os(iOS)
	public typealias KCViewController = UIViewController
#else
	public typealias KCViewController = NSViewController
#endif

public extension KCViewController
{
	#if os(OSX)
	func initWindowAttributes(window win: KCWindow) {
		win.autorecalculatesKeyViewLoop = true
	}
	#endif

	class func loadViewController(name nibname: String) -> KCViewController
	{
		let bundle : Bundle = Bundle(for: KCView.self) ;
		#if os(iOS)
			let nib = UINib(nibName: nibname, bundle: bundle)
			let controllers = nib.instantiate(withOwner: nil, options: nil)
			for i in 0..<controllers.count {
				if let controller = controllers[i] as? KCViewController {
					return controller ;
				}
			}
		#else
			if let nib = NSNib(nibNamed: nibname, bundle: bundle) {
				var controllersp : NSArray? = NSArray()
				if(nib.instantiate(withOwner: nil, topLevelObjects: &controllersp)){
					if let controllers = controllersp {
						for i in 0..<controllers.count {
							if let controller = controllers[i] as? KCViewController {
								return controller
							}
						}
					}
				}
			}
		#endif
		fatalError("Failed to load " + nibname)
	}

	var safeAreaInset: KCEdgeInsets {
		get {
			#if os(OSX)
				let result = KCEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
			#else
				let topmargin: CGFloat
				if self.isPortrait {
					topmargin =  16.0
				} else {
					topmargin =  0.0
				}
				let insets = self.view.safeAreaInsets
				let result = KCEdgeInsets(top:    insets.top    + topmargin,
							  left:   insets.left,
							  bottom: insets.bottom,
							  right:  insets.right)
			#endif
			return result
		}
	}

	#if os(iOS)
	var isPortrait: Bool {
		get {
			if let window = self.view.window {
				if let scene = window.windowScene {
					return scene.interfaceOrientation.isPortrait
				}
			}
			return true
		}
	}
	#endif
}

