/**
 * @file	ViewController.swift
 * @brief	ViewController class for UTWindowController
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import KiwiControls
import Cocoa

private class UTWindowController: NSWindowController
{
	open override func windowDidLoad() {
		super.windowDidLoad()
		Swift.print("windowDidLoad")
    }
}

class ViewController: KCViewController {

@	IBOutlet weak var mStackView: KCStackView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let button0 = KCButton()
		button0.title = "Button-0"
		button0.buttonPressedCallback = {
			[weak self] () -> Void in
			if let myself = self {
				myself.openWindow()
			}
		}
		mStackView.addArrangedSubView(subView: button0)
	}

	private var mWindowController: NSWindowController? = nil

	private func openWindow() {
		Swift.print("*** open window")

		let pref = KCPreference.shared.documentTypePreference
		let utis = pref.UTIs
		Swift.print(" UTI: \(utis)")


		if mWindowController == nil {
			/*
			Swift.print("*** load view controller")
			let delegate = UTViewControllerDelegate()
			let vcont    = KCViewController.loadViewController(delegate: delegate)
			Swift.print("*** allocate window")
			let window   = KCWindow(contentViewController: vcont)
			let wcont    = UTWindowController(window: window)
			Swift.print("*** show window")
			wcont.showWindow(nil)
			mWindowController = wcont
			*/
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}



