/**
 * @file	KCLogWindowController.swift
 * @brief	Define KCLogWindowController class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

public class KCLogWindowController: NSWindowController
{
	private var mStyleListner:	CNObserverDictionary.ListnerHolder?

	private var mConsoleView:	KCConsoleView

	public class func allocateController() -> KCLogWindowController {
		let (window, console, clearbtn) = KCLogWindowController.loadWindow()
		return KCLogWindowController(window: window, consoleView: console, clearButton: clearbtn)
	}

	public required init(window win: NSWindow, consoleView consview: KCConsoleView, clearButton clearbtn: KCButton){
		mConsoleView = consview
		super.init(window: win)
		clearbtn.buttonPressedCallback = {
			/* Send erace entire buffer command */
			let clearcmd = CNEscapeCode.eraceEntireBuffer
			self.mConsoleView.console.print(string: clearcmd.encode())
		}

		let spref = CNPreference.shared.systemPreference
		mStyleListner = spref.addObsertverForStyle(callback: {
			(_ style: CNInterfaceStyle) -> Void in
			self.update(style: style)
		})
	}

	deinit {
		/* Remove color observer */
		if let listner = mStyleListner {
			let spref = CNPreference.shared.systemPreference
			spref.removeObserver(listnerHolder: listner)
		}
	}

	public var console: CNFileConsole {
		get { return mConsoleView.console }
	}

	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public var isVisible: Bool {
		get {
			if let win = self.window {
				return win.isVisible
			} else {
				return false
			}
		}
	}

	public func show() {
		self.window?.orderFront(self.window)
	}

	public func hide() {
		self.window?.orderOut(self.window)
	}

	private class func loadWindow() -> (NSWindow, KCConsoleView, KCButton) {
		if let newwin = loadWindow() {
			/* Setup window */
			newwin.title = "Log"

			/* Console view */
			let cons = KCConsoleView()

			/* Clear button */
			let clearbtn = KCButton()
			clearbtn.value = .text("Clear")
			/* Buttons box */
			let btnframe  = CGRect(origin: CGPoint.zero, size: clearbtn.frame.size)
			let btnbox    = KCStackView(frame: btnframe)
			btnbox.axis = .horizontal
			btnbox.distribution = .fill
			btnbox.addArrangedSubView(subView: clearbtn)
			/* Log box */
			let logwidth  = max(cons.frame.width, clearbtn.frame.width)
			let logheight = cons.frame.height + clearbtn.frame.height
			let logframe  = CGRect(origin: CGPoint.zero, size: CGSize(width: logwidth, height: logheight))
			let logbox    = KCStackView(frame: logframe)
			logbox.axis = .vertical
			logbox.addArrangedSubViews(subViews: [cons, btnbox])
			/* Add contents to window */
			if let root = newwin.contentView as? KCView {
				root.addSubview(logbox)
				root.allocateSubviewLayout(subView: logbox)
			}

			return (newwin, cons, clearbtn)
		} else {
			fatalError("Failed to allocate window")
		}
	}

	private class func loadWindow() -> NSWindow?
	{
		let viewcont = KCViewController.loadViewController(name: "KCEmptyViewController")
		return NSWindow(contentViewController: viewcont)
	}

	private func update(style stl: CNInterfaceStyle) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			guard let win = self.window else {
				NSLog("[Error] No window")
				return
			}
			let vpref = CNPreference.shared.viewPreference
			if let root = win.contentView as? KCView {
				/* Update subviews */
				for subview in root.subviews {
					if let ifview = subview as? KCInterfaceView {
						ifview.updateAppearance()
					}
				}
				/* set background color */
				if let lyr = root.layer {
                    lyr.backgroundColor = vpref.terminalBackgroundColor().cgColor
				}
			} else {
				NSLog("[Error] No root view")
			}
		})
	}
}


