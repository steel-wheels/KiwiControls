/*
 * @file	ViewController.swift
 * @brief	Define ViewController class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import KiwiControls
import CoconutData
import Cocoa

class ViewController: KCMultiViewController
{
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let termctrl = TerminalViewController(parentViewController: self)
		self.pushViewController(viewController: termctrl, callback: {
			(_ val: CNValue) -> Void in
			CNLog(logLevel: .detail, message: "callback: \(String(describing: val.toString()))")
		})
	}

	override func viewDidAppear() {
		/* Enable logging */
		CNPreference.shared.systemPreference.logLevel = .error
		CNLog(logLevel: .error, message: "Hello Log Message !!")
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}


