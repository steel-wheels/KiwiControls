//
//  ViewController.swift
//  UTNavigationBar
//
//  Created by Tomoo Hamada on 2019/01/23.
//  Copyright © 2019 Steel Wheels Project. All rights reserved.
//

import CoconutData
import KiwiControls
import Cocoa

class ViewController: NSViewController
{
	public var console: CNConsole? = nil

	@IBOutlet weak var mNavigationBar: KCNavigationBar!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		mNavigationBar.title = "Hello, World !!"

		mNavigationBar.isLeftButtonEnabled	= true
		mNavigationBar.leftButtonTitle		= "Left"
		mNavigationBar.leftButtonPressedCallback = {
			() -> Void in
			CNLog(logLevel: .debug, message: "Left button pressed")
		}

		mNavigationBar.isRightButtonEnabled	= true
		mNavigationBar.rightButtonTitle		= "Right"
		mNavigationBar.rightButtonPressedCallback = {
			() -> Void in
			CNLog(logLevel: .debug, message: "Right button pressed")
		}

		let _ = KCLogManager.shared
		CNPreference.shared.systemPreference.logLevel = .detail
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

