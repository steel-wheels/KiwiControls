/**
 * @file	KCPlaneViewController.swift
 * @brief	Define KCPlaneViewController class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import CoconutData

open class KCPlaneViewController: KCViewController, KCViewControlEventReceiver
{
	private var mRootView:			KCRootView?

	public init(){
		mRootView		= nil
		super.init(nibName: nil, bundle: nil)
	}

	public required init?(coder: NSCoder) {
		mRootView		= nil
		super.init(coder: coder)
	}

	open override func loadView() {
		//super.loadView() <- Do not call this because it load NIB file (it is NOT exist)
		if mRootView == nil {
			/* Initialize log manager */
			let _ = KCLogWindowManager.shared
			/* Allocate insets */
			let insets: KCEdgeInsets
			#if os(iOS)
			insets = KCEdgeInsets(top: 36.0, left: 0.0, bottom: 0.0, right: 0.0)
			#else  // os(iOS)
			insets = KCEdgeInsets(top:  0.0, left: 0.0, bottom: 0.0, right: 0.0)
			#endif // os(iOS)
			/* Allocate contents by super class */
			let root = KCRootView()
			if let child = loadContext() {
				root.setup(childView: child, edgeInsets: insets)
			} else {
				/* Use default root view to tell error */
				let child = errorContext()
				root.setup(childView: child, edgeInsets: insets)
			}
			/* Assign as root of this controller*/
			self.view = root
			mRootView = root
		}
	}

	open func loadContext() -> KCView? {
		CNLog(logLevel: .error, message: "Override this method", atFunction: #function, inFile: #file)
		return nil
	}

	open func errorContext() -> KCView {
		CNLog(logLevel: .error, message: "Use error context instead of unacceptable user context")
		let boxview = KCStackView()
		boxview.axis = .vertical

		let msgview = KCTextField()
		msgview.isBold	   = false
		msgview.isEditable = false
		msgview.text       = "Failed to load context"
		boxview.addArrangedSubView(subView: msgview)

		return boxview
	}

	open func parentSize() -> CGSize? {
		return nil
	}

	#if os(OSX)
	open override func viewWillLayout() {
		super.viewWillLayout()
		doViewWillLayout()
	}
	#else
	open override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		doViewWillLayout()
	}
	#endif

	#if os(OSX)
	open override func viewDidLayout() {
		doViewDidLayout()
		super.viewDidLayout()
	}
	#else
	open override func viewDidLayoutSubviews() {
		doViewDidLayout()
		super.viewDidLayoutSubviews()
	}
	#endif

	#if os(OSX)
	open override func viewDidAppear() {
		doViewDidAppear()
		super.viewDidAppear()
	}
	#else
	open override func viewDidAppear(_ animated: Bool) {
		doViewDidAppear()
		super.viewDidAppear(animated)
	}
	#endif

	private func doViewWillLayout() {
		if let root = mRootView {
			let maxsize = KCScreen.maxWindowSize()
			if root.hasCoreView {
				/* Layout components */
				CNLog(logLevel: .detail, message: "- [Execute Pre Layout] (root-size=\(root.frame.size.description)")
				let layouter    = KCLayouter()
				layouter.preLayout(rootView: root, maxSize: maxsize)

				/* Resize by the core view */
				#if os(OSX)
				if let window = root.window, let core: KCView = root.getCoreView() {
					let coresize = core.intrinsicContentSize
					self.preferredContentSize = coresize
					window.setContentSize(coresize)
				}
				#endif
			}
		} else {
			CNLog(logLevel: .error, message: "No root view")
		}
	}

	private func doViewDidLayout() {
		/* Keep prefered size */
		if let root = mRootView {
			let maxsize = KCScreen.maxWindowSize()
			if root.hasCoreView {
				let layouter    = KCLayouter()
				layouter.postLayout(rootView: root, maxSize: maxsize)
			}

		} else {
			CNLog(logLevel: .error, message: "No root view")
		}
	}

	private func doViewDidAppear() {
		#if os(OSX)
			if let window = self.view.window, let root = mRootView {
				/* decide 1st responder */
				let decider = KCFirstResponderDecider(window: window)
				let _ = decider.decideFirstResponder(rootView: root)
			} else {
				CNLog(logLevel: .error, message: "No window at \(#function)")
			}
		#endif
	}

	public func notifyControlEvent(viewControlEvent event: KCViewControlEvent) {
		if let root = mRootView {
			switch event {
			case .none:
				break
			case .updateSize(let targview):
				CNLog(logLevel: .detail, message: "Update window size", atFunction: #function, inFile: #file)
				let invalidator = KCLayoutInvalidator(target: targview)
				root.accept(visitor: invalidator)
				//root.invalidateIntrinsicContentSize()
				//root.requireLayout()
			case .switchFirstResponder(let newview):
				#if os(OSX)
					if let window = self.view.window {
						window.makeFirstResponder(newview)
					} else {
						CNLog(logLevel: .error, message: "Failed to switch first responder", atFunction: #function, inFile: #file)
					}
				#else
					newview.becomeFirstResponder()
				#endif
			}
		} else {
			CNLog(logLevel: .error, message: "No root view", atFunction: #function, inFile: #file)
		}
	}
}

