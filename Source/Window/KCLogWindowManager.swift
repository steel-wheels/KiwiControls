/**
 * @file	KCLogWindowManager.swift
 * @brief	Define KCLogWindowManager class
 * @par Copyright
 *   Copyright (C) 2018-2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public class KCLogWindowConsole: CNConsole
{
	private weak var mManager:	KCLogWindowManager?
	private var mConsole:		CNConsole

	public init(console cons: CNConsole, manager mgr: KCLogWindowManager){
		mConsole = cons
		mManager = mgr
	}

	public func print(string str: String) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			self.show() ; self.mConsole.print(string: str)
		})
	}

	public func error(string str: String) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			self.show() ; self.mConsole.error(string: str)
		})
	}

	public func log(string str: String) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			self.show() ; self.mConsole.log(string: str)
		})
	}

	public func scan() -> String? {
		return mConsole.scan()
	}

	private func show(){
		if let mgr = mManager {
			if !mgr.isVisible {
				mgr.doShow()
			}
		}
	}
}


@objc public class KCLogWindowManager: NSObject
{
	public static let shared	= KCLogWindowManager()

	#if os(OSX)
		private var		mWindowController: KCLogWindowController?
	#else
		private weak var	mViewController: KCLogViewController?
	#endif

	private override init() {
		#if os(OSX)
			mWindowController	= nil
		#else
			mViewController		= nil
		#endif
		super.init()
		self.setup()
	}

	deinit {
		/* Connect log buffer to this window */
		CNLogManager.popConsole()
	}

	private func setup(){
		#if os(OSX)
		/* Push log console */
		let cont    = allocController()
		let console = KCLogWindowConsole(console: cont.console, manager: self)
                CNLogManager.pushConsole(console)
		#endif
	}

	#if os(OSX)
	private func allocController() -> KCLogWindowController {
		if let cont = self.mWindowController {
			return cont
		} else {
			let newcont = KCLogWindowController.allocateController()
			self.mWindowController = newcont
			return newcont
		}
	}
	#endif

	public func doShow() {
		#if os(OSX)
		let cont = allocController()
		cont.show()
		#endif
	}

	public func doHide() {
		#if os(OSX)
		let cont = allocController()
		cont.hide()
		#endif
	}

	public var isVisible: Bool {
		get {
			#if os(OSX)
				if let cont = mWindowController {
					return cont.isVisible
				} else {
					return false
				}
			#else
				return false
			#endif
		}
	}
}

