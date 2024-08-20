/**
 * @file	KCMultiViewController.swift
 * @brief	Define KCMultiViewController class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import CoconutData

#if os(iOS)
	public typealias KCMultiViewControllerBase = UITabBarController
#else
	public typealias KCMultiViewControllerBase = NSTabViewController
#endif

open class KCMultiViewController : KCMultiViewControllerBase, KCWindowDelegate
{
	public typealias ViewSwitchCallback = (_ val: CNValue) -> Void

	private var mCallbackStack:	CNStack<ViewSwitchCallback> = CNStack()
	private var mConsoleManager:	KCConsoleManager? = nil
	private var mWindowInitialized:	Bool = false

	public var consoleManager: KCConsoleManager? {
		get { return mConsoleManager }
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		showTabBar(visible:false)

		mConsoleManager = KCConsoleManager()
	}

	#if os(OSX)
	open override func viewWillAppear() {
		super.viewWillAppear()
	}
	#endif

	#if os(OSX)
	open override func viewDidAppear() {
		super.viewDidAppear()
		if let win = self.view.window {
			win.delegate = self
			if !mWindowInitialized {
				self.initWindowAttributes(window: win)
				mWindowInitialized = true
			}
		}
	}
	#endif

	public func showTabBar(visible vis: Bool){
		#if os(OSX)
		let style: NSTabViewController.TabStyle
		if vis {
			style = .segmentedControlOnTop
		} else {
			style = .unspecified
		}
		self.tabStyle = style
		#else
		self.tabBar.isHidden = !vis
		#endif
	}

	open func pushViewController(viewController view: KCSingleViewController, callback cbfunc: @escaping ViewSwitchCallback) {
		/* The current view become background view */
		if let sview = currentViewController() {
			sview.viewWillBecomeBackground()
		}
		/* Push callback */
		mCallbackStack.push(cbfunc)
		#if os(OSX)
			/* Add new item */
			let idx   = self.tabViewItems.count
			let ident = viewIndexToIdentifer(index: idx)
			let item  = NSTabViewItem(identifier: ident)
			item.viewController = view
			self.addTabViewItem(item)
		#else
			let newctrls: Array<KCViewController>
			let idx: Int
			if let orgctrls = self.viewControllers {
				var ctrls = orgctrls
				idx 	 = orgctrls.count
				ctrls.append(view)
				newctrls = ctrls
			} else {
				newctrls = [view]
				idx      = 0
			}
			self.setViewControllers(newctrls, animated: false)
		#endif
		/* Switch to new view */
		switchView(index: idx)
		/* The new view become foreground view */
		if let sview = currentViewController() {
			sview.viewWillBecomeForeground()
		}
	}

	#if os(iOS)
	private var mPickerView: KCDocumentPickerViewController? = nil

	public func documentPickerViewController(callback cbfunc: @escaping KCDocumentPickerViewController.CallbackFunction) -> KCDocumentPickerViewController {
		let newview = KCDocumentPickerViewController(parentViewController: self)
		newview.setCallbackFunction(callback: cbfunc)
		mPickerView = newview
		return newview
	}
	#endif

	open func popViewController(returnValue val: CNValue) -> Bool {
		/* The current view will be removed  */
		if let sview = currentViewController() {
			sview.viewWillRemoved()
		}
		/* Pop callback */
		if let cbfunc = mCallbackStack.pop() {
			cbfunc(val)
		}
		let orgcnt: Int
		#if os(OSX)
			orgcnt = tabViewItems.count
		#else
			if let viewcont = self.viewControllers {
				orgcnt = viewcont.count
			} else {
				orgcnt = 0
			}
		#endif
		guard orgcnt > 1 else {
			CNLog(logLevel: .detail, message: "popViewController -> Failed")
			return false
		}
		/* Switch to previous view */
		let orgidx = orgcnt - 1
		let newidx = orgidx - 1
		switchView(index: newidx)
		/* Remove original view */
		removeTabViewItem(index: orgidx)
		/* The new view will be foreground */
		if let sview = currentViewController() {
			sview.viewWillBecomeForeground()
		}
		return true
	}

	private func removeTabViewItem(index idx: Int) {
		#if os(OSX)
			self.removeTabViewItem(self.tabViewItems[idx])
		#else
			if let orgctrls = self.viewControllers {
				var newctrls: Array<KCViewController> = []
				for i in 0..<idx {
					newctrls.append(orgctrls[i])
				}
				self.setViewControllers(newctrls, animated: false)
			}
		#endif
	}

	private func viewIndexToIdentifer(index idx: Int) -> String {
		return "view\(idx)"
	}

	private func switchView(index idx: Int){
		#if os(OSX)
			self.selectedTabViewItemIndex = idx
		#else
			self.selectedIndex = idx
		#endif
	}

	public func currentViewController() -> KCSingleViewController? {
		#if os(OSX)
			let idx = self.selectedTabViewItemIndex
			if 0 <= idx && idx < self.tabViewItems.count {
				let item = self.tabViewItems[idx]
				if let view = item.viewController as? KCSingleViewController {
					return view
				} else {
					CNLog(logLevel: .error, message: "Unknown view controller", atFunction: #function, inFile: #file)
				}
			}
			return nil
		#else
			if let view = super.selectedViewController as? KCSingleViewController {
				return view
			} else {
				return nil
			}
		#endif
	}
}

