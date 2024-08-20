//
//  ViewController.swift
//  UTConsole
//
//  Created by Tomoo Hamada on 2020/10/31.
//

import KiwiControls
import CoconutData
import Cocoa

class ViewController: KCPlaneViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		let syspref = CNPreference.shared.systemPreference
		syspref.logLevel = .detail

		CNLog(logLevel: .error, message: "Hello, world !!")

		for i in 0..<10 {
			CNLog(logLevel: .warning, message: "Warning \(i)")
		}
	}

	open override func loadViewContext(rootView root: KCRootView) {
		let button = KCButton()
		button.buttonPressedCallback = {
			() -> Void in
			CNLog(logLevel: .detail, message: "Debug message")
		}
		root.setup(childView: button)
		return button.fittingSize
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

